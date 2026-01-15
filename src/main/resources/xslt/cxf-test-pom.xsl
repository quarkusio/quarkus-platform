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

    <xsl:template match="/pom:project[./pom:artifactId/text() = 'quarkus-cxf-integration-test-server']/pom:build/pom:plugins/pom:plugin[./pom:artifactId/text() = 'maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <systemPropertyVariables>
                <quarkus.platform.group-id>${project.groupId}</quarkus.platform.group-id>
                <quarkus.platform.artifact-id>quarkus-bom</quarkus.platform.artifact-id>
                <quarkus.platform.version>${project.version}</quarkus.platform.version>
                <quarkus-cxf.platform.group-id>${project.groupId}</quarkus-cxf.platform.group-id>
                <quarkus-cxf.platform.artifact-id>quarkus-cxf-bom</quarkus-cxf.platform.artifact-id>
                <quarkus-cxf.platform.version>${project.version}</quarkus-cxf.platform.version>
            </systemPropertyVariables>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/pom:project[./pom:artifactId/text() = 'quarkus-cxf-integration-test-server']/pom:profiles/pom:profile[./pom:id/text() = 'native-image']/pom:build/pom:plugins/pom:plugin[./pom:artifactId/text() = 'maven-failsafe-plugin']/pom:executions/pom:execution/pom:configuration/*[local-name() = 'systemPropertyVariables']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <quarkus.platform.group-id>${project.groupId}</quarkus.platform.group-id>
            <quarkus.platform.artifact-id>quarkus-bom</quarkus.platform.artifact-id>
            <quarkus.platform.version>${project.version}</quarkus.platform.version>
            <quarkus-cxf.platform.group-id>${project.groupId}</quarkus-cxf.platform.group-id>
            <quarkus-cxf.platform.artifact-id>quarkus-cxf-bom</quarkus-cxf.platform.artifact-id>
            <quarkus-cxf.platform.version>${project.version}</quarkus-cxf.platform.version>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project[./pom:artifactId/text() = 'quarkus-cxf-integration-test-ws-rm-client']/pom:build/pom:plugins">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <!-- These artifacts need to be present in local maven repo when the test runs -->
            <plugin>
                <groupId>org.codehaus.gmaven</groupId>
                <artifactId>groovy-maven-plugin</artifactId>
                <version>2.1.1</version>
                <executions>
                    <execution>
                        <id>ensure-quarkus-cxf-test-ws-rm-server-downloaded</id>
                        <goals>
                            <goal>execute</goal>
                        </goals>
                        <phase>validate</phase>
                        <configuration>
                            <source>println 'Downloaded quarkus-cxf-test-ws-rm-server-jvm and quarkus-cxf-test-ws-rm-server-native'</source>
                        </configuration>
                    </execution>
                </executions>
                <dependencies>
                    <!-- quarkus-cxf-test-ws-rm-server-jvm uber-jar and quarkus-cxf-test-ws-rm-server-native are run by a test in this module. -->
                    <!-- They both need to be installed in local Maven repository before running this test -->
                    <dependency>
                        <groupId>io.quarkiverse.cxf</groupId>
                        <artifactId>quarkus-cxf-test-ws-rm-server-jvm</artifactId>
                        <classifier>runner</classifier>
                        <version>${quarkus-cxf.version}</version>
                        <exclusions>
                            <exclusion>
                                <groupId>*</groupId>
                                <artifactId>*</artifactId>
                            </exclusion>
                        </exclusions>
                    </dependency>
                    <dependency>
                        <groupId>io.quarkiverse.cxf</groupId>
                        <artifactId>quarkus-cxf-test-ws-rm-server-native</artifactId>
                        <type>exe</type>
                        <version>${quarkus-cxf.version}</version>
                        <exclusions>
                            <exclusion>
                                <groupId>*</groupId>
                                <artifactId>*</artifactId>
                            </exclusion>
                        </exclusions>
                    </dependency>
                </dependencies>
            </plugin>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/pom:project[./pom:artifactId/text() = 'quarkus-cxf-integration-test-ws-rm-client']/pom:build/pom:plugins/pom:plugin[./pom:artifactId/text() = 'maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <systemPropertyVariables>
                <quarkus-cxf.version>${quarkus-cxf.version}</quarkus-cxf.version>
            </systemPropertyVariables>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/pom:project[./pom:artifactId/text() = 'quarkus-cxf-integration-test-ws-rm-client']/pom:profiles/pom:profile[./pom:id/text() = 'native-image']/pom:build/pom:plugins/pom:plugin[./pom:artifactId/text() = 'maven-failsafe-plugin']/pom:executions/pom:execution/pom:configuration/*[local-name() = 'systemPropertyVariables']">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <quarkus-cxf.version>${quarkus-cxf.version}</quarkus-cxf.version>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
