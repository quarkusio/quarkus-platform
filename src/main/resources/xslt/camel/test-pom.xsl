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

    <xsl:template match="/pom:project/pom:properties">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-solr'">
                <solr.trust-store>${project.basedir}/target/ssl/trust-store.jks</solr.trust-store>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project/pom:dependencies">
        <!-- prepend properties before dependencies if necessary -->
        <xsl:if test="(not(/pom:project/pom:properties)) and (/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-solr')">
            <properties>
                <solr.trust-store>${project.basedir}/target/ssl/trust-store.jks</solr.trust-store>
            </properties>
        </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-debezium'">
                <!-- Camel Quarkus cannot depend on the GPL2 licensed mysql-connector-java directly due to ASF legal policy -->
                <dependency>
                    <groupId>org.apache.camel.quarkus</groupId>
                    <artifactId>camel-quarkus-debezium-mysql</artifactId>
                </dependency>
                <dependency>
                    <groupId>mysql</groupId>
                    <artifactId>mysql-connector-java</artifactId>
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
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-solr'">
                <plugin>
                    <groupId>org.codehaus.mojo</groupId>
                    <artifactId>exec-maven-plugin</artifactId>
                    <executions>
                        <execution>
                            <id>extend-default-trust-store-extension</id>
                            <phase>test-compile</phase>
                            <goals>
                                <goal>java</goal>
                            </goals>
                            <configuration>
                                <mainClass>org.apache.camel.quarkus.test.ExtendDefaultTrustStore</mainClass>
                                <arguments>
                                    <argument>${solr.trust-store}</argument>
                                    <argument>ssl/solr-ssl.der</argument>
                                </arguments>
                                <includePluginDependencies>true</includePluginDependencies>
                            </configuration>
                        </execution>
                    </executions>
                    <dependencies>
                        <dependency>
                            <groupId>org.apache.camel.quarkus</groupId>
                            <artifactId>camel-quarkus-integration-test-support</artifactId>
                            <version>${camel-quarkus-test-list.version}</version>
                        </dependency>
                        <dependency>
                            <groupId>org.apache.camel.quarkus</groupId>
                            <artifactId>camel-quarkus-integration-test-solr</artifactId>
                            <version>${camel-quarkus-test-list.version}</version>
                            <classifier>tests</classifier>
                        </dependency>
                    </dependencies>
                </plugin>
            </xsl:if>
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>build-helper-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>reserve-network-port</id>
                        <goals>
                            <goal>reserve-network-port</goal>
                        </goals>
                        <phase>process-test-resources</phase>
                        <configuration>
                            <portNames>
                                <portName>test.http.port.jvm</portName>
                                <portName>test.https.port.jvm</portName>
                                <portName>test.http.port.native</portName>
                                <portName>test.https.port.native</portName>
                            </portNames>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </xsl:copy>
    </xsl:template>

  <!-- Forward solr.trust-store to the tests via surefire plugin -->
    <xsl:template match="//*[local-name() = 'systemPropertyVariables']">
        <xsl:copy>
            <xsl:if test="/pom:project/pom:artifactId/text() = 'camel-quarkus-integration-test-solr'">
                <javax.net.ssl.trustStore>${solr.trust-store}</javax.net.ssl.trustStore>
            </xsl:if>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
