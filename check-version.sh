#! /bin/bash

TAG=$1
QUARKUS_VERSION=$(./mvnw help:evaluate -Dexpression=quarkus.version -q -DforceStdout)

if [[ "${TAG}" != "${QUARKUS_VERSION}" ]]; then
  echo "ERROR: Quarkus version in POM (${QUARKUS_VERSION}) is not the same as \$TAG (${TAG})"
  exit 1
fi

exit 0
