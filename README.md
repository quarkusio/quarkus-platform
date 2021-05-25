# Quarkus Platform

[![Version](https://img.shields.io/github/v/tag/quarkusio/quarkus-platform?style=for-the-badge)](https://github.com/quarkusio/quarkus-platform/tags/latest)
[![Build Status](https://img.shields.io/azure-devops/build/quarkus-ci/quarkus/12?style=for-the-badge&logo=azure-pipelines)](https://dev.azure.com/quarkus-ci/quarkus/_build/latest?definitionId=12)
[![License](https://img.shields.io/github/license/quarkusio/quarkus-platform?style=for-the-badge&logo=apache)](https://www.apache.org/licenses/LICENSE-2.0)
[![Project Chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg?style=for-the-badge)](https://quarkusio.zulipchat.com/)


Quarkus Platform aggregates extensions from the [Quarkus Core repository](https://github.com/quarkusio/quarkus) and a set of other extensions developed by the Quarkus community
into a single development stack that targets the primary use-cases of the Quarkus platform. The Quarkus platform includes an integration testsuite to make sure the extensions included
into the platform do not create conflicts for each other and can be used in the same application in any combination.
More information about how a Quarkus platform is defined can be found in the [Platform Guide](https://quarkus.io/guides/platform).


## Platform coordination mailing list

If you are a Quarkus Platform participant, it is highly recommended to subscribe to the [quarkus-platform-coordination mailing list](https://groups.google.com/g/quarkus-platform-coordination).

It is a low traffic list which aims to facilitate the coordination of the Platform releases and to share important Platform-related changes.

## Platform project

Quarkus platform is a project that brings various Quarkus extensions together aligning their dependency constraints to make sure they do not create conflicts for each other.
This project does not include any code at this point but it does use tools that collect the original dependency contraints of each extension as an input and generates
a [set of platform artifacts](https://quarkus.io/guides/platform#quarkus-platform-artifacts) that represent a platform build.

## Platform members

A platform member represents a Quarkus extension project that includes one or more Quarkus extensions that are integrated into the platform.

### Quarkus core

[Quarkus Core](https://github.com/quarkusio/quarkus) is an essential member of the platform and is dominant during the dependency constraint alignment in a sense that its dependency constraints
are immutable, i.e. other platform members will be adapted to comply with the Quarkus core requirements and not the other way around.

### Platform member input

Quarkus platform members are expected to provide:
* the dependency constraints their extensions require at Quarkus application build and run times (typically in the form of a Maven BOM artifact);
* a list of test Maven artifacts that can be integrated into the Quarkus platform integration testsuite (usually, it would be some of the original tests from the extension project that are released
along with the extension as Maven `test-jar` artifacts).

The Quarkus platform BOM generator will perform an alignment across all the platform member dependency constraints and will generate a BOM for each platform member
that is compatible with all the other platform members.
Once all the member BOMs have been generated, the platform integration testsuite (consisting of the tests contributed by all the members) will be run against the generated platform BOMs.
As long as *all* the platform integration tests pass, the generated platform member BOMs (and a few other related artifacts), representing a single compatible development stack, can be released.

### Generated platform member artifacts

The platform project build will generate the following artifacts for each member.

#### BOM

Member-specific dependency constraints that are aligned with other platform members. Applications developed in compliance with a Quarkus platform will be importing platform member BOMs that belong to the same platform release.
E.g. a platform may include extensions from [Camel Quarkus](https://github.com/apache/camel-quarkus) and [Kogito Runtimes](https://github.com/kiegroup/kogito-runtimes), in which case a platform release will include a `quarkus-camel-bom`
and a `quarkus-kogito-bom`. Then applications using Camel extensions will be importing the `quarkus-camel-bom`, application using Kogito extensions will be importing `quarkus-kogito-bom` and applications using Camel and Kogito extensions
at the same time will be importing both `quarkus-camel-bom` and `quarkus-kogito-bom`.

**NOTE** The ordering of member BOM imports in applications should not be significant, given that member BOMs are aligned as part of the platform build.

#### JSON descriptor

This artifact contains member extension metadata that is important for the Quarkus devtools used by application developers to discover extensions suitable for their projects.

#### Properties

At a minimum, this artifact includes information about the platform release. This information is used by the Quarkus application build bootstrap mechanism to make sure the platform member BOMs imported by the application belong to the same
platform release and fail the build or log a warning in case that is not the case. This is done to make sure application developers do not import member BOMs that belong different platform releases by mistake.

## Platform project configuration and build

The platform is currently configured in a single Maven POM file (the root `pom.xml`) with the exception of a few additional resource files. This POM file includes a few Maven plugin configuration generating the platform artifacts and a `platformConfig` configuration.

**IMPORTANT** Maven build process launched from the root project directory will generate the complete platform Maven project (during the `process-resources` phase) in the `generated-platform-project` directory. The generated platform project
should not be modified manually except for local testing purposes. The project will be re-generated on every platform build launched from the root platform project directory.

The `generated-platform-project` will refer to the root platform project `pom.xml` as its parent POM and so may inherit properties and other common configuration from it.

### Generate the platform project

`mvn process-resources` will generate the complete platform project.

The platform project will typically be generated on every build anyway. But this command could be used in case you want to simply (re-)generate the platform project w/o running any other commands on it.

**NOTE** the way it's currently done is any command launched from the platform project's root dir will be passed to the `generated-platform-project`, which means `mvn process-resources` will not only generate the platform project but will also be executed against it.

### Building the platform

`mvn install` launched from the platform project's root directory will (re-)generate the `generated-platform-project`, build, test and (assuming the tests have passed) install the generated platform artifacts into the local Maven repository.

### Testing the platform

`mvn test` or `mvn verify` launched from the root platform project directory will (re-)generate the `generated-platform-project` and execute all the JVM tests of all the members.

`mvn verify -Dnative` launched from the root platform project directory will (re-)generate the `generated-platform-project` and execute all the JVM and native tests of all the members.

Once the platform project has been generated and installed in the local Maven repository. Platform members can analyze the artifacts generated for their extensions and run their testsuite in isolation from the rest of the platform testsuite
by navigating to the desired test module and using `mvn` commands they typically would use to run their extension tests.

## Generated platform project layout

The `generated-platform-project` is a multimodule project. It will contain one module per platform member. E.g.

```shell
[aloubyansky@localhost quarkus-platform]$ ls generated-platform-project -l
total 48
-rw-rw-r-- 1 aloubyansky aloubyansky 1377 May 27 16:35 pom.xml
drwxrwxr-x 5 aloubyansky aloubyansky 4096 May 27 16:35 quarkus
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-blaze-persistence
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-camel
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-cassandra
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-debezium
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-hazelcast
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-kogito
drwxrwxr-x 3 aloubyansky aloubyansky 4096 May 28 08:32 quarkus-maven-plugin
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-optaplanner
drwxrwxr-x 6 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-qpid-jms
drwxrwxr-x 5 aloubyansky aloubyansky 4096 May 27 16:35 quarkus-universe
```

* The `quarkus` module represents the [Quarkus Core](https://github.com/quarkusio/quarkus) member.
* The `quarkus-maven-plugin` module re-publishes the `io.quarkus:quarkus-maven-plugin` from the [Quarkus Core](https://github.com/quarkusio/quarkus) under the platform's Maven groupId and version to simplify configurations of Quarkus application using the platform.
* The `quarkus-universe` module reprsents the legacy `io.quarkus:quarkus-universe-bom` platform.

Other modules above represent actual platform members. Every member module will have the same layout, e.g.

```shell
[aloubyansky@localhost quarkus-platform]$ ls generated-platform-project/quarkus-camel -l
total 28
drwxrwxr-x   2 aloubyansky aloubyansky  4096 May 28 08:32 bom
drwxrwxr-x   3 aloubyansky aloubyansky  4096 May 28 08:32 descriptor
drwxrwxr-x 121 aloubyansky aloubyansky 12288 May 28 08:32 integration-tests
-rw-rw-r--   1 aloubyansky aloubyansky   767 May 27 16:35 pom.xml
drwxrwxr-x   4 aloubyansky aloubyansky  4096 May 27 16:35 properties
```

The `bom` module will contain a member-specific generate Maven BOM that is aligned with all the other generated member BOMs. This BOM will be a part of the platform release.

The `descriptor` module will contain a JSON artifact in its `target` directory which is generated from the member BOM artifact and will be a part of the platform release.

The `properties` module will contain a `properties` artifact in its `target` directory and will be a part of the platform release.

The `integration-tests` module will contain test modules generated for the tests configured in the root platform `pom.xml` for the member. There will be one module per each configured test. The tests are excluded from the platform release.




## Platform BOM generation

The basic principle of the Quarkus Platform BOM Generator is:

1. Version constraints defined in `io.quarkus:quarkus-bom` will not be mutated and will be dominating during the dependency constraint alignment across all the platform members.
1. Every other platform member BOM will be processed in the following way:
   1. if it appears to be importing any version of `io.quarkus:quarkus-bom`, the set of the dependency version constraints included into that version of `io.quarkus:quarkus-bom`
will be subtracted from the member BOM.
   1. The remaining set of the dependency version constraints from the member BOM will be organized into groups. With each group containing artifacts coming from the same origin,
i.e. artifacts that appear to be modules of the same multi-module project release.
   1. For each group of such artifacts, the generator will check whether the `io.quarkus:quarkus-bom` the platform is based on includes any artifacts from the same origin.
And if it does, it will try to align the versions of those artifacts with the project release version used in the `io.quarkus:quarkus-bom` (highlighting the differences/conflicts in the generated reports).
   1. If the `io.quarkus:quarkus-bom` did not appear to contain any artifacts from the same origin as the group, then every other imported member BOM is checked for including artifacts
from the same origin. If such artifacts are found then the newer version of those artifacts will be preferred.

### BOM generator reports

Besides generating the member BOMs, the BOM generator will also generate HTML reports for highlighting how the differences between the original dependency version constraints
and the generated ones for every member. The reports can be found under the `target/reports` directory of the root platform project dir.

## Release steps

1. Use the Maven Release Plugin to tag and deploy to the Sonatype OSS Nexus: 

        TAG=0.0.5 && mvn release:prepare release:perform -DdevelopmentVersion=999-SNAPSHOT -DreleaseVersion=$TAG -Dtag=$TAG -DperformRelease -Prelease

    Hint: You can also append `-DskipTests -Darguments=-DskipTests` to the command above to skip tests

2. Go to https://s01.oss.sonatype.org/#stagingRepositories and close the repository there.
3. Once the checks pass, click on the `Release` button and wait until it gets percolated to Central
 
---
**IMPORTANT**

Due to the Apache process, it is possible that the Apache Camel artifacts may not be directly available in Maven central, therefore you need to add the following profile to your ~/.m2/settings.xml:

```xml
     <profiles>
        <profile>
            <id>camel-staging</id>
            <repositories>
                <repository>
                    <id>apache-camel-staging</id>
                    <url>https://repository.apache.org/content/repositories/orgapachecamel-1161/</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </repository>
            </repositories>
            <pluginRepositories>
                <pluginRepository>
                    <id>apache-camel-staging</id>
                    <url>https://repository.apache.org/content/repositories/orgapachecamel-1161/</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </pluginRepository>
            </pluginRepositories>
        </profile>
    </profiles>
    <activeProfiles>
        <activeProfile>camel-staging</activeProfile>
    </activeProfiles>    
```
