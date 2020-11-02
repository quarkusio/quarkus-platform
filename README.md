# Quarkus Platform

[![Version](https://img.shields.io/github/v/tag/quarkusio/quarkus-platform?style=for-the-badge)](https://github.com/quarkusio/quarkus-platform/tags/latest)
[![Build Status](https://img.shields.io/azure-devops/build/quarkus-ci/quarkus/12?style=for-the-badge&logo=azure-pipelines)](https://dev.azure.com/quarkus-ci/quarkus/_build/latest?definitionId=12)
[![License](https://img.shields.io/github/license/quarkusio/quarkus-platform?style=for-the-badge&logo=apache)](https://www.apache.org/licenses/LICENSE-2.0)
[![Project Chat](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg?style=for-the-badge)](https://quarkusio.zulipchat.com/)


Quarkus Platform aggregates extensions from Quarkus Core and those developed by the community into a single tested, compatible and versioned set
that can be used by application developers to align the dependency versions of their applications with those verified by the platform testsuite.

## Platform coordination mailing list

If you are a Quarkus Platform participant, it is highly recommended to subscribe to the [quarkus-platform-coordination mailing list](https://groups.google.com/g/quarkus-platform-coordination).

It is a low traffic list which aims to facilitate the coordination of the Platform releases and to share important Platform-related changes.

## Platform BOMs

The main artifact that represents the platform, as a set of extensions and their dependencies, is `io.quarkus:quarkus-universe-bom`. This BOM
is imported by application developers to align the dependencies of their applications with the chosen Quarkus Platform version.

The original version of the `io.quarkus:quarkus-universe-bom` is defined in the `bom/pom.xml`. However, this is not the actual version of the BOM that will be
installed in the Maven repository. Instead, the original version of the BOM will be used as an input to the [Quarkus Platform BOM Generator](https://github.com/quarkusio/quarkus-platform-bom-generator)
that will produce a BOM with dependency versions properly aligned across all the platform participants at the same time filtering out outdated and
non-existent dependencies.

### Platform BOM generation

IMPORTANT: In BOMs whatever is listed or imported earlier dominates over what is listed or imported later. However, this Quarkus Platform BOM Generator
does not follow that principle generating the final BOM!

This is done for two reasons:
1. the version constraints defined in `io.quarkus:quarkus-bom` should always dominate (that does not necessarily contradict the BOM rule above, given that `io.quarkus:quarkus-bom` is usually imported first);
2. to treat extensions imported into the platform fairly wrt the version constraints they contribute to the platform.

Here is the basic principle of how the Quarkus Platform BOM Generator works:

1. The version of the `io.quarkus:quarkus-bom` imported by the original `io.quarkus:quarkus-universe-bom` will be the dominating source of the dependency version constraints.
Version constraints defined in `io.quarkus:quarkus-bom` will be copied to the generated platform BOM without changes.
1. Every extension BOM imported by the original `io.quarkus:quarkus-universe-bom` will be processed in the following way:
   1. if it appears to be importing any version of `io.quarkus:quarkus-bom`, the set of the dependency version constraints included into that version of `io.quarkus:quarkus-bom`
will be subtracted from the extension BOM.
   1. The remaining set of the dependency version constraints from the extension BOM will be split into groups. With each group containing artifacts coming from the same origin,
i.e. artifacts that appear to be modules of the same multi-module project release.
   1. For each group of such artifacts, the generator will check whether `io.quarkus:quarkus-bom` includes artifacts from the same origin. And if it does, it will try to align
the versions of those artifacts with the project release version used in `io.quarkus:quarkus-bom` (highlighting the differences/conflicts in the generated reports).
   1. If `io.quarkus:quarkus-bom` did not appear to contain artifacts with the same origin as the group, then every other imported extension BOM is checked for including artifacts
from the same origin. If such artifacts are found then the newer version of those artifacts will be preferred.

#### Generated Output

The BOM generator will actually produce more than one BOM. Besides generating the `io.quarkus:quarkus-universe-bom` it will also generate
BOMs for every imported extension (which is not a part of `io.quarkus:quarkus-bom`). Every generated extension BOM will basically be the original
extension BOM but aligned with the dependency version constraints from the `io.quarkus:quarkus-universe-bom`. The purpose of generating extension
BOMs is simply to highlight which version constraints relevant to the extension have actually been included into the generated `io.quarkus:quarkus-universe-bom`
and debug possible incompatibilities.

The generated BOMs and various reports will be found under `bom/target/boms`. This directory will contain:
* `index.html` - the main HTML page with all the reports detailing potential conflicts and diffs.
* a directory per each generated BOM with the name following `<bom-groupId>.<bom-artifactId>-version` format and containing:
  * `pom.xml` - the generated POM (BOM);
  * `diff.html` - the differences between the original version of the BOM and the generated one;
  * `original-releases.html` - multi-module project releases detected in the original version of the BOM;
  * `generated-releases.html` - multi-module project releases detected in the generated version of the BOM.

## Integration testsuite

At this point, Quarkus Core extension tests are not included into the platform testsuite. There are two reasons for that:
1. Quarkus Core tests aren't available as Maven artifacts;
2. Given that Quarkus Core dependencies dominate in the platform, Quarkus Core tests are supposed to always pass.

All other extensions contributed by the community **must** include their tests into the platform testsuite.

The testsuite is expected to include tests for both JVM and native-image modes. The native-image tests are enabled with `-Dnative` command
line argument.

### Testsuite layout

Given that the platform BOM is generated, the testsuite projects can not belong to the same project as the platform BOM. Simply because
they would see the original version of the BOM instead of the generated one. And we definitely want to run the tests against the platform BOM
that will be installed in the Maven repository. For that reason the BOM project and the testsuite projects are separated.

The root project includes module `integration-tests` whose `pom.xml` imports the `io.qaurkus:quarkus-universe-bom` and other necessary constraints.
It also configures the `maven-invoker-plugin` in its `pluginManagement` section. This `pom.xml` will actually be the parent of all the extension test
projects.

`integration-tests` project defines submodules: one module per imported extension. Each such extension module includes a `pom.xml` that configures the invoker.
Actually, it simply mentions the `maven-invoker-plugin` inheriting its configuration from `integration-tests/pom.xml`. The invoker targets directory called `invoked`,
which is found in every extension module of `intergation-tests`.
IMPORTANT: `invoked` directory is not added as a `module` of the extension tests project! This is very important, since this is what separates the extension tests
from the main Quarkus platform project.

The `invoked` directory contains the `root` directory (actually it's not important how it's called, the `maven-invoker-plugin` is configured to look into `invoked` directory
then it invoke projects found under it), which is the actual extension integration tests project root directory.

Normally, it will contain at least two modules:
* `rpkgtests` that is preparing the imported extension test artifacts to be usable as test sources with proper dependencies (basically, it repackages
the test jars to make the test scope dependencies visible to the Maven resolver);
* a module configuring specific test execution. Normally, it will depend on the artifact produced by `rpkgtests` and configure the `maven-failsafe-plugin` to look for tests
from that artifact.

### Running Tests

All the JVM tests will of course be run as part of `mvn clean install`.

To enable native tests simply add `-Dnative` to the command line.

#### Running Extension-specific Tests

The integration tests do rely on the presence of the following artifacts in the Local maven repository
* `io.quarkus:quarkus-universe-bom` - the platform BOM;
* `io.quarkus:quarkus-universe-integration-tests-parent` - the parent of every integration test project.

The quickest way to install them would be:

`mvn clean install -DskipTests`

Once the platform BOM and the parent POMs have been installed, it's possible to

`cd integration-tests/<extension-dir>/invoked/root`

and run the necessary `mvn` commands. However, this approach assumes the platform BOM doesn't change between the test runs, i.e. it does not have to be regenerated.

The following command could be used in cases when the platform BOM has to be regenerated before running the extension tests:

`mvn clean install -pl bom,integration-tests/<extension-dir>`

If an extension has integration tests organized in modules then the following command can be used to regenerate the platform BOM and run the specific submodule tests (assuming the `rpkgtests` artifact does not have to be regenerated):

`mvn clean install -pl bom,integration-tests/<extension-dir> -Dinvoker.test=root/<module-dir>`

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
