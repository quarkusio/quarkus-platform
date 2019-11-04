# Quarkus Platform

[![Version](https://img.shields.io/github/v/tag/quarkusio/quarkus-platform?style=for-the-badge)](https://github.com/quarkusio/quarkus-platform/tags/latest)
[![Build Status](https://img.shields.io/azure-devops/build/quarkus-ci/quarkus/12?style=for-the-badge&logo=azure-pipelines)](https://dev.azure.com/quarkus-ci/quarkus/_build/latest?definitionId=12)
[![License](https://img.shields.io/github/license/quarkusio/quarkus-platform?style=for-the-badge&logo=apache)](https://www.apache.org/licenses/LICENSE-2.0)
[![Project Chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg?style=for-the-badge)](https://quarkusio.zulipchat.com/)


Quarkus Platform aggregates extensions from Quarkus Core and those developed by the community into a single tested, compatible and versioned set
that can be used by application developers to align the dependency versions of their applications with those verified by the platform testsuite.

## Integration testsuite

At this point, Quarkus Core extension tests are not included into the platform testsuite. There are two reasons for that:
1. Quarkus Core tests aren't available as Maven artifacts;
2. Given that Quarkus Core dependencies dominate in the platform, Quarkus Core tests are supposed to always pass.
However, we may want to reconsider that and add at least some of the Quarkus Core tests in the near future.

All other extensions contributed by the community **must** include their tests into the platform testsuite.

`integration-tests/camel-core` could be used as a template for integrating new tests.

The testsuite is expected to include tests for both JVM and native-image modes. The native-image tests are enabled with `-Dnative` command
line argument.

## Platform BOMs

The main artifact that represents the platform, as a set of extensions and their dependencies, is `quarkus-platform-bom`. This BOM
can be imported by application developers to align dependencies of their applications with the chosen Quarkus Platform version.

`quarkus-platform-bom` should always be importing `io.quarkus:quarkus-bom:xxx` before any other dependencies to make sure
that the Quarkus Core dependencies are not overriden by other dependencies and to guarantee that the Quarkus Core testsuite will
not be broken.

`quarkus-platform-bom-deployment` imports `quarkus-platform-bom` then `io.quarkus:quarkus-bom-deployment` then everything else.

Both of the BOMs are flattened.

## Release steps

1. Use the Maven Release Plugin to tag and deploy to the Sonatype OSS Nexus: 

        TAG=0.0.5 && mvn release:prepare release:perform -DdevelopmentVersion=999-SNAPSHOT -DreleaseVersion=$TAG -Dtag=$TAG -DperformRelease -Prelease

    Hint: You can also append `-DskipTests -Darguments=-DskipTests` to the command above to skip tests

2. Go to https://oss.sonatype.org/#stagingRepositories and close the repository there.
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
