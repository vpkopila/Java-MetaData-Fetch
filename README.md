# Java Project Metadata Extraction - Approaches and Automation

This document outlines methods for extracting metadata from Java-based applications, specifically focusing on Maven, Gradle (Groovy/Kotlin), and JEE-based projects. It provides three practical approaches for automating metadata collection for auditing, migration, analysis, or documentation purposes.

### Overview of Metadata Extraction Approaches

| S.No | Approach/Method                     | Description |
|---|----------------------------|-------------|
| 1 | **Approach 1 :** **PowerShell Script**      | A unified script to extract both project metadata from Maven, Gradle, and JEE applications. |
| 2 | **Approach 2 :** **Maven (Surefire Plugin)**| Extracts project metadata from `pom.xml` and captures runtime environment details (e.g., Java version, OS, user info) during test execution. |
| 3 | **Approach 3 :** **Gradle (Groovy Snippet)**| Custom script in `build.gradle/gradle.kts` to collect build metadata and runtime environment properties (e.g., system properties, locale, Java version). |


---

## 1. Approach 1: (PowerShell Script Usage)

A PowerShell-based utility to extract metadata from Java project build files (Gradle, Maven, JEE), such as:

* Build tool type and version
* Packaging type (JAR, WAR, EAR)
* Group ID / Artifact ID / Version
* Plugins and dependencies
* Java version and system info
* Project description and encoding

### Supported Build Files

* `build.gradle` (Groovy DSL)
* `build.gradle.kts` (Kotlin DSL)
* `pom.xml` (Maven)
* `web.xml`, `application.xml` (JEE)

### Script File

Please find the PowerShell script : [*Get-JavaMetaData.ps1*](/Script/Get-JavaMetaData.ps1).

###  1.1. Sample Input Commands for the script

*Maven File*

```powershell
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\pom.xml"
```

*Gradle (Groovy DSL)*

```powershell
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\build.gradle"
```

*Gradle (Kotlin DSL)*

```powershell
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\build.gradle.kts"
```

*JEE (web.xml / application.xml)*

```powershell
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\web.xml"
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\application.xml"
```

*Optional Output Files*

```powershell
.\Get-JavaMetaData.ps1 -BuildFilePath "C:\POC\..\pom.xml" -JsonOut "my-output.json" -CsvOut "my-output.csv"
```

### 1.2. PowerShell Script - Result Table

Please find result : [*Table format of result captured by PowerShell script*](https://github.com/vpkopila/Java-MetaData-Fetch/blob/main/SampleResults/ResultTables.md#powershell-script-result)

---

## 2. Approach 2: (Maven - Surefire Plugin)

The **Maven Surefire Plugin** runs unit tests during the Maven lifecycle (`test` phase) and is included by default in Spring Boot through `spring-boot-starter-test`, metadata is Extracted from `<properties>` from test result file.

### Output Path Structure

```
Application (Root or module folder)
└── build
    └── test-results
        └── test
            └── TEST-com.example.demo.DemoApplicationTests.xml
```

### 2.1. Maven result: Captured Metadata Example (Table Format)

Please find result : [*Table format of result captured for Maven app*](https://github.com/vpkopila/Java-MetaData-Fetch/blob/main/SampleResults/ResultTables.md#maven-resultsurefire-plugin)

### 2.2. Maven Result: Result File (XML Example)

Please find result : [*XML format of result captured for Maven app(generated)*](/SampleResults/results.xml)

---

## 3. Approach 3: (Gradle)

Gradle does not have a direct equivalent to the Maven Surefire plugin but can still capture system properties via custom test configurations.

### 3.1. Snippet: Capture Properties in `build.gradle`

```groovy
test {
    useJUnitPlatform()

    testLogging {
        events "passed", "skipped", "failed"
        showStandardStreams = true
    }

    doFirst {
        def props = System.getProperties()
        def file = file("$buildDir/test-results/test/system-properties.xml")
        file.parentFile.mkdirs()
        file.withWriter('UTF-8') { writer ->
            writer.println '<?xml version="1.0" encoding="UTF-8"?>'
            writer.println '<properties>'
            props.each { k, v ->
                writer.println "  <property name=\"${k}\" value=\"${v}\"/>"
            }
            writer.println '</properties>'
        }
    }
}
```

### 3.2. Gradel Result: Metadata Captured (XML Example)

Please find result : [*XML format of result captured for Gradle app(original)*](/SampleResults/results.xml)

### 3.3. Gradle Result: Metadata Captured (Table Format)

Please find result : [*Table format of result captured for Gradle app*](https://github.com/vpkopila/Java-MetaData-Fetch/blob/main/SampleResults/ResultTables.md#gradle-result)

---
## 4. Capturing Git Info

### 4.1. Maven: Using `git-commit-id-plugin`

#### Step 1: Add Plugin to `pom.xml`

```xml
<build>
  <plugins>
    <plugin>
      <groupId>pl.project13.maven</groupId>
      <artifactId>git-commit-id-plugin</artifactId>
      <version>4.13.1</version>
      <executions>
        <execution>
          <goals>
            <goal>revision</goal>
          </goals>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

#### Step 2: Run Maven Build

```bash
mvn clean install
```

#### Step 3: Output Location

```
target/classes/git.properties
```

#### Step 4: Example Output

```properties
git.branch=main
git.commit.id=abc123def456
git.commit.time=2025-09-05T13:20:30Z
git.commit.user.name=Your Name
git.commit.message.full=Fix NPE on user login
git.tags=v1.2.3
```

---

### 4.2. Gradle: Using `com.gorylenko.gradle-git-properties`

#### Step 1: Apply Plugin in `build.gradle`

```groovy
plugins {
    id 'com.gorylenko.gradle-git-properties' version '2.4.1'
}
```

#### Step 2: Run Build

```bash
./gradlew build
```

#### Step 3: Output Location

```
build/resources/main/git.properties
```

#### Step 4: Example Output

```properties
git.branch=main
git.commit.id=abc123def456
git.commit.time=2025-09-05T13:25:00Z
git.commit.user.name=Your Name
git.commit.message.full=Add support for Git commit capture
git.tags=v2.0.0
```

#### Step 5: Optional Configuration

```groovy
gitProperties {
    keys = [
        'git.branch',
        'git.commit.id',
        'git.commit.time',
        'git.commit.user.name',
        'git.commit.message.full'
    ]
    dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    dateFormatTimeZone = "UTC"
}
```

---

### 4.3. Kotlin DSL Version (`build.gradle.kts`)

#### Step 1: Apply Plugin

```kotlin
plugins {
    id("com.gorylenko.gradle-git-properties") version "2.4.1"
}
```

#### Step 2: Optional Configuration

```kotlin
gitProperties {
    keys.set(
        listOf(
            "git.branch",
            "git.commit.id",
            "git.commit.time",
            "git.commit.user.name",
            "git.commit.message.full"
        )
    )
    dateFormat.set("yyyy-MM-dd'T'HH:mm:ssZ")
    dateFormatTimeZone.set("UTC")
}
```

#### Step 3: Run Build

```bash
./gradlew build
```

#### Step 4: Output Location

```
build/resources/main/git.properties
```

#### Step 5: Example Output

```properties
git.branch=main
git.commit.id=abc123def456
git.commit.time=2025-09-05T13:25:00Z
git.commit.user.name=Your Name
git.commit.message.full=Add support for Git commit capture
```

---
