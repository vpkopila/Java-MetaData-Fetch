# INPUT
# Maven file
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\pom.xml"

# Gradle Groovy
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\build.gradle"

# Gradle Kotlin DSL
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\build.gradle.kts"

# JEE (Web.XML)
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\web.xml"
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\application.xml"

# Optionally specify output file names
# .\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\JavaBuildMetaData\pom.xml" -JsonOut "my-output.json" -CsvOut "my-output.csv"

param (
    [string]$BuildFilePath = "C:\POC\pom.xml",  # or build.gradle or web.xml
    [string]$JsonOut       = "metadata-output.json",
    [string]$CsvOut        = "metadata-output.csv"
)

function Get-Value($primary, $fallback = "") {
    if ($primary) { return $primary }
    elseif ($fallback) { return $fallback }
    else { return "" }
}

# Validate and normalize path
$BuildFilePath = Resolve-Path $BuildFilePath
if (!(Test-Path $BuildFilePath)) {
    Write-Error "File not found: $BuildFilePath"
    exit 1
}

# File setup
$fileName   = [System.IO.Path]::GetFileName($BuildFilePath).ToLower()
$projectDir = Split-Path $BuildFilePath -Parent

# Metadata storage
$metadata = [ordered]@{}
$plugins  = @()
$deps     = @()

# ========== MAVEN BLOCK ==========
if ($fileName -eq "pom.xml") {
    Write-Host "Detected Maven Project"
    try {
        [xml]$pomXml = Get-Content $BuildFilePath -Raw
    } catch {
        Write-Error "Invalid pom.xml"
        exit 1
    }

    $metadata["Build Tool"] = "Maven"

    $mvnVersionOutput = & mvn -v 2>&1
    $mvnVersionLine = $mvnVersionOutput | Where-Object { $_ -match "^Apache Maven\s+[\d\.]+" }
    $metadata["Build Tool Version"] = if ($mvnVersionLine) {
        ($mvnVersionLine -replace "^Apache Maven\s+", "").Trim()
    } else {
        "Unknown"
    }

    $metadata["Group ID"]        = Get-Value $pomXml.project.groupId $pomXml.project.parent.groupId
    $metadata["Artifact ID"]     = $pomXml.project.artifactId
    $metadata["Version"]         = Get-Value $pomXml.project.version $pomXml.project.parent.version
    $metadata["Packaging"]       = $pomXml.project.packaging
    $metadata["Name"]            = $pomXml.project.name
    $metadata["Description"]     = $pomXml.project.description
    $metadata["URL"]             = $pomXml.project.url
    $metadata["App Java Version"]= $pomXml.project.properties.'java.version'
    $metadata["Encoding"]        = $pomXml.project.properties.'project.build.sourceEncoding'
    $metadata["Spring Boot Version"] = $pomXml.project.properties.'spring-boot.version'
    $metadata["Inception Year"]  = $pomXml.project.inceptionYear
    $metadata["Developer Name"]  = $pomXml.project.developers.developer.name
    $metadata["Developer Email"] = $pomXml.project.developers.developer.email
    $metadata["SCM URL"]         = $pomXml.project.scm.url
    $metadata["System Java"]     = (& java -version 2>&1)[0]

    $profiles = $pomXml.project.profiles.profile | ForEach-Object { $_.id }
    $metadata["Profiles"] = if ($profiles) { $profiles -join ", " } else { "None" }

    $pomXml.project.dependencies.dependency | ForEach-Object {
        $deps += "$($_.groupId):$($_.artifactId):$($_.version)"
    }

    $pomXml.project.build.plugins.plugin | ForEach-Object {
        $plugins += "$($_.groupId):$($_.artifactId):$($_.version)"
    }

    # Detect authentication libraries
    $authLibraryMap = @{
        "spring-boot-starter-security" = "Spring Security"
        "spring-security"              = "Spring Security"
        "oauth2"                       = "OAuth2"
        "jjwt"                         = "JWT"
        "java-jwt"                     = "JWT"
        "spring-security-jwt"          = "JWT"
        "keycloak"                     = "Keycloak"
        "shiro"                        = "Apache Shiro"
        "javax.security"               = "JAAS"
        "jaas"                         = "JAAS"
        "jakarta.security"             = "Jakarta Security"
    }

    $authTypesFound = @()
    foreach ($lib in $authLibraryMap.Keys) {
        foreach ($dep in $deps) {
            if ($dep -match $lib) {
                $authTypesFound += $authLibraryMap[$lib]
                break
            }
        }
    }

    $authTypesFound = $authTypesFound | Sort-Object -Unique
    $metadata["Authentication"] = if ($authTypesFound.Count -gt 0) {
        "Yes (" + ($authTypesFound -join ", ") + ")"
    } else {
        "No"
    }

} 
# ========== GRADLE BLOCK ==========
elseif ($fileName -eq "build.gradle" -or $fileName -eq "build.gradle.kts") {
    Write-Host "Detected Gradle Project"

    $content = Get-Content -Raw -Path $BuildFilePath

    # =====================
    # Extract Plugin Names
    # =====================
    $plugins = @()

    if ($fileName -eq "build.gradle") {
        # Groovy DSL: plugins { id 'java' }
        $pluginPattern = '(?s)plugins\s*\{(.*?)\}'
        $pluginMatch = [regex]::Match($content, $pluginPattern)
        if ($pluginMatch.Success) {
            $pluginBlock = $pluginMatch.Groups[1].Value -split "`r?`n"
            foreach ($line in $pluginBlock) {
                $trim = $line.Trim()
                if ($trim -ne '' -and -not $trim.StartsWith('//')) {
                    # Correct regex with properly escaped quotes
                    $idMatch = [regex]::Match($trim, "id\s+['""]([^'""]+)['""]")
                    if ($idMatch.Success) {
                        $plugins += $idMatch.Groups[1].Value
                    }
                }
            }
        }
    }
    else {
        # Kotlin DSL: plugins { id("java") }
        $ktsPluginPattern = "(?i)id\s*\(\s*['""]([^'""]+)['""]\s*\)"
        $pluginMatches = [regex]::Matches($content, $ktsPluginPattern)
        foreach ($match in $pluginMatches) {
            $plugins += $match.Groups[1].Value
        }
    }

    # ======================
    # Extract Dependencies
    # ======================
    $deps = @()

    if ($fileName -eq "build.gradle") {
        # Groovy DSL dependencies block
        $depsPattern = '(?s)dependencies\s*\{(.*?)\}'
        $depsMatch = [regex]::Match($content, $depsPattern)
        if ($depsMatch.Success) {
            $depBlock = $depsMatch.Groups[1].Value -split "`r?`n"
            foreach ($line in $depBlock) {
                $trim = $line.Trim()
                if ($trim -ne '' -and -not $trim.StartsWith('//')) {
                    $deps += $trim
                }
            }
        }
    }
    else {
        # Kotlin DSL dependencies: implementation("group:artifact:version")
        $ktsDepPattern = "(?i)(implementation|api|compile|runtimeOnly|testImplementation|testCompile)\s*\(\s*['""]([^'""]+)['""]\s*\)"
        $depMatches = [regex]::Matches($content, $ktsDepPattern)
        foreach ($match in $depMatches) {
            $deps += "$($match.Groups[1].Value): $($match.Groups[2].Value)"
        }
    }

    # ============================
    # Metadata Extraction Function
    # ============================
    function Extract-Metadata {
        param($field, $content)
        $pattern = "(?m)^\s*$field\s*=\s*['""](.+?)['""]"
        $match = [regex]::Match($content, $pattern)
        if ($match.Success) {
            return $match.Groups[1].Value
        } else {
            return ""
        }
    }

    $group   = Extract-Metadata -field "group" -content $content
    $version = Extract-Metadata -field "version" -content $content
    $desc    = Extract-Metadata -field "description" -content $content
    $name    = Split-Path $BuildFilePath -Parent | Split-Path -Leaf

    # ==================
    # Java Version
    # ==================
    $javaVerPattern = '(?s)java\s*\{.*?languageVersion.*?=\s*JavaLanguageVersion\.of\((\d+)\).*?\}'
    $javaMatch = [regex]::Match($content, $javaVerPattern)
    $javaVersion = if ($javaMatch.Success) { $javaMatch.Groups[1].Value } else { "Unknown" }

    # ==================
    # Build Tool Info
    # ==================
    $metadata["Build Tool"] = "Gradle"
    $gradleVersionOut = & gradle -v 2>&1
    $gradleVersion = ($gradleVersionOut | Select-String "^Gradle\s+\d") -replace "^Gradle\s*", ""
    $metadata["Build Tool Version"] = $gradleVersion.Trim()

    # ==================
    # Metadata Fields
    # ==================
    $metadata["Group ID"]     = if ($group) { $group } else { "unknown.group" }
    $metadata["Artifact ID"]  = $name
    $metadata["Version"]      = if ($version) { $version } else { "0.0.1" }
    $metadata["Description"]  = $desc
    $metadata["Java Version"] = $javaVersion
    $metadata["System Java"]  = (& java -version 2>&1)[0]
    $metadata["Encoding"]     = "UTF-8"

    # ==================
    # Packaging Detection
    # ==================
    $packaging = "Unknown"
    if ($plugins -contains "war") {
        $packaging = "war"
    }
    elseif ($plugins -contains "ear") {
        $packaging = "ear"
    }
    elseif ($plugins -contains "java") {
        $packaging = "jar"
    }
    $metadata["Packaging"] = $packaging

    # Optionally, store plugins and dependencies
    $metadata["Plugins"] = $plugins -join ", "
    $metadata["Dependencies"] = $deps -join "; "
}
# ========== JEE BLOCK ==========
elseif ($fileName -eq "web.xml" -or $fileName -eq "application.xml") {
    Write-Host "Detected Java Enterprise (Jakarta EE) Application"

    $metadata["Build Tool"]   = if (Test-Path "$projectDir\build.xml") { "Ant" } else { "Manual or Unknown" }
    $metadata["App Type"]     = "Java EE"
    $metadata["System Java"]  = (& java -version 2>&1)[0]
    $metadata["Encoding"]     = "UTF-8"
    $metadata["Packaging"]    = if (Test-Path "$projectDir\WEB-INF") { "war" } elseif (Test-Path "$projectDir\META-INF") { "ear" } else { "Unknown" }
    $metadata["Name"]         = Split-Path $projectDir -Leaf
    $metadata["Version"]      = "Unknown"

    # Extract from web.xml if it exists
    $webXmlPath = "$projectDir\WEB-INF\web.xml"
    if (Test-Path $webXmlPath) {
        [xml]$webXml = Get-Content $webXmlPath -Raw
        $metadata["Display Name"]  = $webXml.'web-app'.'display-name'
        $metadata["Description"]   = $webXml.'web-app'.description
        $metadata["Servlet Version"] = $webXml.'web-app'.version

        # Collect servlet/filter names
        $servlets = $webXml.'web-app'.servlet | ForEach-Object { $_.'servlet-name' }
        $filters  = $webXml.'web-app'.filter | ForEach-Object { $_.'filter-name' }

        $metadata["Servlets"] = if ($servlets) { $servlets -join ", " } else { "None" }
        $metadata["Filters"]  = if ($filters)  { $filters  -join ", " } else { "None" }
    }

    # Extract from application.xml if exists (EAR project)
    $appXmlPath = "$projectDir\META-INF\application.xml"
    if (Test-Path $appXmlPath) {
        [xml]$appXml = Get-Content $appXmlPath -Raw
        $modules = $appXml.'application'.module | ForEach-Object {
            $_.'web'.'web-uri'
        }
        $metadata["Modules"] = if ($modules) { $modules -join ", " } else { "None" }
    }

    # Try extracting encoding from Ant build.xml if available
    $buildXmlPath = "$projectDir\build.xml"
    if (Test-Path $buildXmlPath) {
        [xml]$buildXml = Get-Content $buildXmlPath -Raw
        $encoding = $buildXml.project.property | Where-Object { $_.name -eq "encoding" } | Select-Object -ExpandProperty value
        if ($encoding) {
            $metadata["Encoding"] = $encoding
        }
    }

    # Output dummy dependencies and plugins if needed
    $plugins  = @("Manual or Ant-based plugins not detected automatically")
    $deps     = Get-ChildItem -Recurse -Path "$projectDir\lib" -Include *.jar -ErrorAction SilentlyContinue | ForEach-Object { $_.Name }
}
# ========== UNKNOWN FILE ==========
else {
    Write-Error "Unsupported build file: $fileName"
    exit 1
}
# ========== OUTPUT ==========
Write-Host "`nProject Metadata:"
$metadata.GetEnumerator() | ForEach-Object {
    Write-Host ("{0,-18}: {1}" -f $_.Key, $_.Value)
}

Write-Host "`nPlugins:"
if ($plugins.Count -eq 0) { Write-Host " - None found" }
else { $plugins | ForEach-Object { Write-Host " - $_" } }

Write-Host "`nDependencies:"
if ($deps.Count -eq 0) { Write-Host " - None found" }
else { $deps | ForEach-Object { Write-Host " - $_" } }

# ========== EXPORT TO JSON ==========
$fullExport = @{
    Metadata     = $metadata
    Plugins      = $plugins
    Dependencies = $deps
}
$fullExport | ConvertTo-Json -Depth 10 | Out-File $JsonOut -Encoding UTF8
Write-Host "`nExported JSON to $JsonOut"

# ========== EXPORT TO CSV ==========
$metadataClean = [PSCustomObject]@{}
foreach ($key in $metadata.Keys) {
    $value = if ($null -ne $metadata[$key]) { $metadata[$key].ToString() } else { "" }
    Add-Member -InputObject $metadataClean -MemberType NoteProperty -Name $key -Value $value
}
$metadataClean | Export-Csv -Path $CsvOut -NoTypeInformation -Encoding UTF8
Write-Host "Exported CSV to $CsvOut"
