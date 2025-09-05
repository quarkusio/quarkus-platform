<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:pom="http://maven.apache.org/POM/4.0.0" xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xalan="http://xml.apache.org/xslt" exclude-result-prefixes="pom xalan">

    <xsl:output method="xml" indent="yes" xalan:indent-amount="2" />
    <xsl:strip-space elements="*" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project/pom:build/pom:plugins/pom:plugin[pom:artifactId='maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'quarkus-hazelcast-client-integration-tests'">
                <excludes>
                    <exclude>**/HazelcastAtomicTest.java</exclude>
                </excludes>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
