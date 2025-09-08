# PowerShell Script Result:

| Category               | Input Name             | Example Values                                                                 | Java Build Flags / Identifiers                                                                                     | Maven Script Support                                                                 | Gradle Script Support                          |
|------------------------|------------------------|----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|------------------------------------------------|
| Build Tool             | Build System           | Maven, Gradle, Ant                                                               | pom.xml, build.gradle, build.xml                                                                                     | Yes (pom.xml parsing)                                                               | Yes                                            |
| Runtime Information    | JDK / JVM Version      | Java 8, Java 11, Java 17, Java 21                                                | java.version, maven.compiler.source, targetCompatibility (Gradle), <java.version> in Maven properties               | Yes (from properties and compiler settings)                                        | Yes                                            |
| Target Framework       | Java Platform          | Java SE, Jakarta EE, Spring Boot                                                 | <packaging>, spring-boot-starter-* dependencies, or presence of javax.*, jakarta.*, org.springframework.* packages  | Yes (partial) (via packaging and dependencies)                                     | Yes (partial)                                  |
| Runtime Version        | JVM Version            | 17.0.1, 11.0.19                                                                   | java -version output, JAVA_HOME                                                                                      | Yes (via java -version and JAVA_HOME)                                              | Yes                                            |
| Startup Instrumentation| Startup Logs / Middleware| System.out.println("Started"), Logger.info, @Bean logs                         | Logging frameworks: Log4j, SLF4J, Logback, Spring Boot @PostConstruct, ApplicationRunner, CommandLineRunner         | No                                                                                 | No                                             |
| Embedded Language Usage| Scripting Language APIs| Python, Nashorn, Kotlin Script                                                   | javax.script.ScriptEngineManager, groovy.lang.*, kotlin.script.*                                                    | No                                                                                 | No                                             |
| Technology Stack       | Project Type           | Spring Boot App, JavaFX App, CLI, WAR                                            | packaging, presence of Spring Boot starter dependencies, JavaFX modules, mainClassName, application plugin in Gradle| Yes (partial) (detects packaging and common dependencies)                         | Yes (partial)                                  |
| Web Framework          | Web Stack              | Spring MVC, Jakarta REST, Struts, JSF                                            | Dependencies like spring-webmvc, jakarta.ws.rs, struts-core, javax.faces.*                                          | Yes (via declared dependencies)                                                    | Yes (via deps)                                 |
| ORM / Data Access      | ORM Framework          | Hibernate, JPA, MyBatis, JDBC                                                    | Dependencies: hibernate-core, spring-boot-starter-data-jpa, mybatis, javax.persistence.*                            | Yes (via dependencies)                                                             | Yes                                            |
| Authentication         | Security Mechanism     | Spring Security, OAuth2, JWT, JAAS                                               | Dependencies: spring-security-*, javax.security.*, annotations like @EnableWebSecurity                              | Yes (via dependencies and annotations)                                             | Yes                                            |
| Dependencies           | Maven/Gradle Artifacts | com.fasterxml.jackson.core, org.mapstruct, etc.                                  | <dependency> blocks in pom.xml, implementation or api lines in build.gradle(.kts)                                   | Yes (directly parsed from <dependency> elements)                                   | Yes                                            |
| Assembly References    | Library Imports        | java.sql, javax.servlet, org.springframework.*                                   | Imports in source or .class files (not in current script)                                                            | No (Cannot detect exact imports from source or class files via script)            | No                                             |
| Custom Libraries       | Internal JARs          | com.company.common, internal-utils.jar                                           | .jar files in lib directory or classpath (not parsed by current script)                                             | No (Can detect custom dependencies in pom.xml; cannot detect unreferenced jars)    | No                                             |
| SDK Version            | Build Tool Version     | Gradle 7.6.2, Maven 3.9.1                                                         | distributionUrl in gradle-wrapper.properties, mvn -v, gradle -v                                                     | No                                                                                 | No                                             |
| Environment Settings   | Profiles / Modes       | dev, staging, prod                                                                | spring.profiles.active, Maven profiles, system properties                                                            | Yes (via Maven profiles)                                                           | No                                             |
| Deployment             | Build Configuration    | dev, release, snapshot                                                            | Maven build profiles, Gradle buildType, system properties                                                            | Yes (basic) (basic support via Maven profiles)                                     | No                                             |
| Deployment Method      | Hosting Method         | WAR to Tomcat, JAR (fat), Docker, Kubernetes                                     | Detected via packaging, Dockerfile, spring-boot-maven-plugin, Helm charts                                           | Yes (partial) (packaging and plugins)                                              | Yes (partial)                                  |
| Output Type            | Artifact Type          | JAR, WAR, EAR                                                                     | <packaging> in pom.xml, Gradle application or java-library plugin                                                   | Yes (via <packaging> element)                                                      | Yes                                            |

# Maven Result(Surefire plugin)


| Category           | Metadata Name                        | Field Fetched / Value Preview                                                                 |
|--------------------|--------------------------------------|-----------------------------------------------------------------------------------------------|
|  Application Info  | APPLICATION_NAME                     | metafetch                                                                                    |
|                    | LOGGED_APPLICATION_NAME              | [metafetch]                                                                                  |
| Java Environment | java.version                         | 17.0.15                                                                                      |
|                    | java.vendor                          | Microsoft                                                                                    |
|                    | java.vm.name                         | OpenJDK 64-Bit Server VM                                                                     |
|                    | java.home                            | C:\Users\v-pkopila\OneDrive - Microsoft\downloads-PC\OPenJDK17\jdk-17.0.15+6                |
|                    | java.runtime.version                 | 17.0.15+6-LTS                                                                                |
|                    | java.vm.version                      | 17.0.15+6-LTS                                                                                |
|                    | java.vm.vendor                       | Microsoft                                                                                    |
|                    | java.vm.info                         | mixed mode, sharing                                                                          |
|                    | java.vm.specification.name           | Java Virtual Machine Specification                                                           |
|                    | java.vm.specification.vendor         | Oracle Corporation                                                                           |
|                    | java.vm.specification.version        | 17                                                                                           |
|                    | java.vendor.version                  | Microsoft-11369865                                                                           |
|                    | java.vendor.url                      | https://www.microsoft.com                                                                    |
|                    | java.vendor.url.bug                  | https://github.com/microsoft/openjdk/issues                                                  |
|                    | java.runtime.name                    | OpenJDK Runtime Environment                                                                  |
|                    | jdk.debug                            | release                                                                                      |
|                    | sun.java.launcher                   | SUN_STANDARD                                                                                 |
|                    | sun.management.compiler              | HotSpot 64-Bit Tiered Compilers                                                              |
|                    | sun.arch.data.model                  | 64                                                                                           |
|                    | sun.cpu.isalist                      | amd64                                                                                        |
|                    | sun.cpu.endian                       | little                                                                                       |
|                    | sun.os.patch.level                   | (empty)                                                                                      |
|                    | sun.io.unicode.encoding              | UnicodeLittle                                                                                |
|  Java Specification  | java.specification.version           | 17                                                                                           |
|                    | java.specification.vendor            | Oracle Corporation                                                                           |
|                    | java.specification.name              | Java Platform API Specification                                                              |
|                    | java.specification.maintenance.version | 1                                                                                          |
|  Classpath   | java.class.path                      | (Long list of JARs – see original)                                                           |
|  Testing     | surefire.test.class.path             | (Long test classpath – see original)                                                         |
|                    | surefire.real.class.path             | C:\Users\v-pkopila\AppData\Local\Temp\surefire...jar                                        |
|                    | sun.java.command                     | C:\Users\v-pkopila\AppData\Local\Temp\surefire...jar ...                                     |
|  User Info   | user.name                            | v-pkopila                                                                                    |
|                    | user.home                            | C:\Users\v-pkopila                                                                           |
|                    | user.country                         | IN                                                                                           |
|                    | user.language                        | en                                                                                           |
|                    | user.timezone                        | Asia/Calcutta                                                                                |
|                    | user.dir                             | C:\POC\metafetch                                                                             |
|                    | user.variant                         | (empty)                                                                                      |
|                    | user.script                          | (empty)                                                                                      |
|  OS          | os.name                              | Windows 11                                                                                   |
|                    | os.arch                              | amd64                                                                                        |
|                    | os.version                           | 10.0                                                                                         |
|  Filesystem  | file.separator                       | \                                                                                             |
|                    | line.separator                       | \n (displayed as &#10; in XML)                                                               |
|                    | path.separator                       | ;                                                                                           |
|                    | java.io.tmpdir                       | C:\Users\V-PKOP~1\AppData\Local\Temp\                                                        |
|  Encoding    | file.encoding                        | Cp1252                                                                                       |
|                    | sun.jnu.encoding                     | Cp1252                                                                                       |
|                    | native.encoding                      | Cp1252                                                                                       |
|                    | FILE_LOG_CHARSET                     | windows-1252                                                                                 |
|                    | CONSOLE_LOG_CHARSET                  | windows-1252                                                                                 |
|  IDE         | idea.version                         | 2023.3.4                                                                                     |
|  Miscellaneous  | basedir                              | C:\POC\metafetch                                                                             |
|                    | PID                                  | 28968                                                                                        |
|                    | java.class.version                   | 61.0                                                                                         |
|                    | java.vm.compressedOopsMode           | Zero based                                                                                   |
|                    | localRepository                      | C:\Users\v-pkopila\.m2\repository                                                            |
|                    | java.library.path                    | (Long path – includes bin folders, Maven, Gradle, Python, etc.)                              |


# Gradle Result:

| Category              | Metadata Name                   | Field Fetched / Value Preview                                                              |
|-----------------------|----------------------------------|--------------------------------------------------------------------------------------------|
|  Application Info  | sun.java.launcher               | SUN_STANDARD                                                                               |
|                       | user.script                     | (empty)                                                                                   |
|                       | java.vendor.url.bug             | https://github.com/microsoft/openjdk/issues                                               |
|  Build Info        | sun.boot.library.path            | C:\Users\v-pkopila\OneDrive - Microsoft\downloads-PC\OPenJDK17\jdk-17.0.15+6\bin          |
|  Classpath         | java.class.path                 | C:\Users\v-pkopila.gradle\wrapper\dists...                                                |
|                       | java.class.version              | 61.0                                                                                      |
|  Encoding           | sun.jnu.encoding                | Cp1252                                                                                     |
|                       | file.encoding                   | windows-1252                                                                               |
|                       | native.encoding                 | Cp1252                                                                                     |
|                       | sun.io.unicode.encoding         | UnicodeLittle                                                                              |
|  Environment Paths  | java.library.path               | (truncated long path)                                                                      |
|                       | library.jansi.path              | C:\Users\v-pkopila.gradle\native\jansi\1.18\windows64                                     |
|  Filesystem         | file.separator                 | \                                                                                          |
|                       | line.separator                 | (newline)                                                                                  |
|                       | path.separator                 | ;                                                                                          |
|                       | java.io.tmpdir                 | C:\Users\V-PKOP~1\AppData\Local\Temp\                                                      |
|  IDE                | idea.version                   | 2023.3.4                                                                                   |
|                       | idea.active                    | true                                                                                       |
|                       | idea.vendor.name               | JetBrains                                                                                  |
|  Java Environment   | java.version                   | 17.0.15                                                                                     |
|                       | java.runtime.version           | 17.0.15+6-LTS                                                                              |
|                       | java.runtime.name              | OpenJDK Runtime Environment                                                                |
|                       | java.home                      | C:\Users\v-pkopila\OneDrive - Microsoft\downloads-PC\OPenJDK17\jdk-17.0.15+6              |
|                       | java.vendor                    | Microsoft                                                                                  |
|                       | java.vendor.url                | https://www.microsoft.com                                                                 |
|                       | java.vendor.version            | Microsoft-11369865                                                                         |
|                       | java.vm.name                   | OpenJDK 64-Bit Server VM                                                                   |
|                       | java.vm.version                | 17.0.15+6-LTS                                                                              |
|                       | java.vm.vendor                 | Microsoft                                                                                  |
|                       | java.vm.info                   | mixed mode, sharing                                                                        |
|                       | java.version.date              | 2025-04-15                                                                                 |
|                       | java.vm.compressedOopsMode     | 32-bit                                                                                     |
|  Java Specification  | java.specification.version       | 17                                                                                        |
|                       | java.specification.name         | Java Platform API Specification                                                            |
|                       | java.specification.vendor       | Oracle Corporation                                                                         |
|                       | java.specification.maintenance.version | 1                                                                                      |
|                       | java.vm.specification.version   | 17                                                                                         |
|                       | java.vm.specification.name      | Java Virtual Machine Specification                                                         |
|                       | java.vm.specification.vendor    | Oracle Corporation                                                                         |
|  Logging Config     | jdk.debug                      | release                                                                                    |
|  Maven Config       | java.vendor.url.bug             | https://github.com/microsoft/openjdk/issues                                               |
|  OS                  | os.name                        | Windows 11                                                                                 |
|                       | os.arch                        | amd64                                                                                      |
|                       | os.version                     | 10.0                                                                                       |
|                       | sun.cpu.isalist               | amd64                                                                                      |
|                       | sun.os.patch.level            | (empty)                                                                                    |
|  System Hardware    | sun.arch.data.model            | 64                                                                                         |
|                       | sun.management.compiler        | HotSpot 64-Bit Tiered Compilers                                                            |
|                       | sun.cpu.endian                 | little                                                                                     |
|                       | sun.java.command               | org.gradle.launcher.daemon.bootstrap.GradleDaemon 8.14.3                                   |
|  Testing            | java.vm.specification.vendor    | Oracle Corporation                                                                         |
|  User Info          | user.name                      | v-pkopila                                                                                  |
|                       | user.language                 | en                                                                                         |
|                       | user.timezone                 | Asia/Calcutta                                                                              |
|                       | user.home                     | C:\Users\v-pkopila                                                                         |
|                       | user.country                  | IN                                                                                         |
|                       | user.dir                      | C:\POC\metafetch_gradle\demo                                                               |
|                       | user.variant                  | (empty)                                                                                    |

