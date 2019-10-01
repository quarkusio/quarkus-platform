# Quarkus Platform

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
