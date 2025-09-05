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

    <xsl:template match="/pom:project/pom:dependencies">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-debezium'">
                <!-- Camel Quarkus cannot depend on the GPL2 licensed mysql-connector-java directly due to ASF legal policy -->
                <dependency>
                    <groupId>org.apache.camel.quarkus</groupId>
                    <artifactId>camel-quarkus-debezium-mysql</artifactId>
                </dependency>
                <dependency>
                    <groupId>com.mysql</groupId>
                    <artifactId>mysql-connector-j</artifactId>
                </dependency>
                <dependency>
                    <groupId>org.apache.camel.quarkus</groupId>
                    <artifactId>camel-quarkus-debezium-sqlserver</artifactId>
                </dependency>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project/pom:build/pom:plugins">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-js-dsl'">
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-dependency-plugin</artifactId>
                    <executions>
                        <execution>
                            <id>unpack-test-resources</id>
                            <phase>process-test-resources</phase>
                            <goals>
                                <goal>unpack</goal>
                            </goals>
                            <configuration>
                                <artifactItems>
                                    <artifactItem>
                                        <groupId>org.apache.camel.quarkus</groupId>
                                        <artifactId>camel-quarkus-integration-test-js-dsl</artifactId>
                                        <version>${camel-quarkus.version}</version>
                                        <outputDirectory>${project.basedir}/src/main/resources</outputDirectory>
                                        <includes>**/*.mjs</includes>
                                    </artifactItem>
                                </artifactItems>
                            </configuration>
                        </execution>
                    </executions>
                </plugin>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project/pom:build/pom:plugins/pom:plugin[pom:artifactId='maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-hazelcast'">
                <excludes>
                    <exclude>**/HazelcastAtomicTest.java</exclude>
                </excludes>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
