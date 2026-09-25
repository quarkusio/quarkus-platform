# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Read the README first

**[README.md](README.md) is the reference documentation for this repository and it is thorough.** Read it before doing anything non-trivial here — it covers what a platform member is, every `platformConfig` element, how to override dependency versions, the BOM generation algorithm and the generated project layout. Do not guess at configuration syntax; look it up there.

This file only carries the few things an agent needs on top of it.

## What this project is

A configuration-only project: no application code. The whole platform is defined in the root `pom.xml` plus a couple of resource files under `src/main/resources/`. The `quarkus-platform-bom-maven-plugin` generates the real multi-module Maven project into `generated-platform-project/` during the `process-resources` phase of every build.

## Working rules

- **Never hand-edit anything under `generated-platform-project/`.** It is overwritten on every build. Change the root `pom.xml` instead.
- **After changing `pom.xml`, run `./mvnw -Dsync` and commit the regenerated `generated-platform-project/` files together with the change.** CI fails if they are out of sync.
- Verify configuration changes by running `./mvnw -Dsync` and reading the diff in `generated-platform-project/*/bom/pom.xml`. The generator is happy to accept configuration that silently produces nothing, so a clean build is not evidence that a change took effect.

## Build commands

```bash
# Regenerate the platform project only
./mvnw -Dsync

# Generate + build + test + install to the local repo
./mvnw install

# All JVM tests
./mvnw verify

# JVM + native tests
./mvnw verify -Dnative

# A single member's tests (after an initial install)
cd generated-platform-project/quarkus-camel/integration-tests/camel-quarkus-integration-test-core
mvn verify
```
