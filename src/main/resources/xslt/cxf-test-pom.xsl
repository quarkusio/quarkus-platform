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

    <xsl:template match="/pom:project/pom:build/pom:plugins">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'quarkus-cxf-integration-test-ws-rm-client'">
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
                                <source>
                                    println 'Downloaded quarkus-cxf-test-ws-rm-server-jvm and quarkus-cxf-test-ws-rm-server-native'
                                </source>
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
            </xsl:if>

            <!-- Workaround for https://github.com/quarkiverse/quarkus-cxf/issues/1292 -->
            <xsl:if test="/pom:project/pom:artifactId/text() = 'quarkus-cxf-integration-test-mtls'">
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
                                        <groupId>io.quarkiverse.cxf</groupId>
                                        <artifactId>quarkus-cxf-integration-test-mtls</artifactId>
                                        <version>${quarkus-cxf.version}</version>
                                        <outputDirectory>${project.basedir}/target/classes</outputDirectory>
                                        <includes>*.pkcs12</includes>
                                    </artifactItem>
                                </artifactItems>
                            </configuration>
                        </execution>
                    </executions>
                </plugin>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
