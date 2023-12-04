#! /bin/bash

if [ $# -eq 0 ]; then
    echo "Release version required"
    exit 1
fi
VERSION=$1

sed -ri "s@        <quarkus\.version>[^<]+</quarkus\.version>@        <quarkus.version>${VERSION}</quarkus.version>@g" pom.xml
./mvnw -Dsync
