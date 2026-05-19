# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

This is the **Quarkus Platform** — a configuration-only project (no application code) that aggregates Quarkus Core and community extensions into a unified, tested platform. The entire platform is defined in a single `pom.xml` and a few resource files. A Maven plugin (`quarkus-platform-bom-maven-plugin`) generates the actual multi-module Maven project in `generated-platform-project/` during every build.

**Do not manually edit files under `generated-platform-project/`** — they are regenerated on every build.

## Build Commands

```bash
# Regenerate the platform project (run after any pom.xml changes, before committing)
./mvnw -Dsync

# Full build: generate + build + test + install to local repo
./mvnw install

# Run all JVM tests
./mvnw verify

# Run JVM + native tests
./mvnw verify -Dnative

# Build a specific member's tests only (after initial install)
cd generated-platform-project/quarkus-camel/integration-tests/camel-quarkus-integration-test-core
mvn verify
```

After changing `pom.xml`, always run `./mvnw -Dsync` and commit the regenerated `generated-platform-project/` changes. CI will fail if the generated project is out of sync.

## Project Structure

- **`pom.xml`** — The single source of truth. Contains all version properties, member definitions, and the `<platformConfig>` section that drives generation.
- **`generated-platform-project/`** — Auto-generated multi-module Maven project. Each member gets submodules: `bom/`, `descriptor/`, `integration-tests/`, `properties/`.
- **`src/main/resources/xslt/`** — XSLT templates applied to generated test POMs (for adding dependencies, excluding specific test classes, etc.).
- **`src/main/resources/extensions-overrides.json`** — Overrides extension metadata in generated descriptors (e.g., marking extensions as unlisted).

## Platform Configuration (`pom.xml`)

All platform configuration lives inside `<platformConfig>` in the root `pom.xml`:

- **`<core>`** — Quarkus Core member (its constraints are immutable and take precedence).
- **`<members>/<member>`** — Each community extension member. Key elements:
  - `<bom>` — The member's upstream BOM coordinates
  - `<tests>/<test>` — Test artifacts to include in integration testing
  - `<defaultTestConfig>` — Default test settings for all tests in a member

### Test Configuration Elements (on `<test>` or `<defaultTestConfig>`)

| Element | Purpose |
|---------|---------|
| `<skip>true</skip>` | Skip the entire test module (`maven.test.skip`) |
| `<excluded>true</excluded>` | Remove the test module from generation entirely |
| `<skipJvm>true</skipJvm>` | Skip JVM test runs only |
| `<skipNative>true</skipNative>` | Skip native test runs only |
| `<jvmExcludes>**/SomeTest*</jvmExcludes>` | Exclude specific test classes from JVM runs (surefire/failsafe pattern) |
| `<nativeExcludes>**/SomeTest*</nativeExcludes>` | Exclude specific test classes from native runs |
| `<groups>!native</groups>` | JUnit test group filter |
| `<nativeGroups>native</nativeGroups>` | JUnit group filter for native only |
| `<mavenFailsafePlugin>true</mavenFailsafePlugin>` | Use failsafe instead of surefire |
| `<transformWith>path/to/xslt</transformWith>` | Apply XSLT transform to the generated test POM |
| `<systemProperties>`, `<jvmSystemProperties>`, `<nativeSystemProperties>` | Pass system properties |
| `<pomProperties>` | Set Maven properties in the generated test POM |
| `<dependencies>`, `<testDependencies>` | Add extra dependencies (should be avoided) |

### Global Test Exclusion

Surefire and Failsafe are configured globally to exclude tests tagged with `@Tag("quarkus-platform-ignore")`.

## Version Management

All member versions are defined as properties in the root `pom.xml` (e.g., `<camel-quarkus.version>`, `<quarkus-langchain4j.version>`). The `$` sign in generated properties is escaped using the `<dollarSign>` property.

## BOM Generation Algorithm

1. Quarkus Core constraints are **immutable** — they always win.
2. For each member BOM, constraints are aligned: same-origin artifacts get unified versions, with Core taking precedence, then preferring the newer version among members.
3. Aligned BOMs are generated per member under `generated-platform-project/<member>/bom/`.

## CI

CI runs `./mvnw -B clean install --fail-at-end` and separately checks whether `generated-platform-project/` is in sync. The sync check runs `process-resources` and fails if any files differ from what's committed.
