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

    <xsl:template match="/pom:project[./pom:artifactId/text() = 'camel-quarkus-integration-test-hazelcast']/pom:build/pom:plugins/pom:plugin[pom:artifactId='maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <excludes>
                <exclude>**/HazelcastAtomicTest.java</exclude>
            </excludes>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project[./pom:artifactId/text() = 'camel-quarkus-integration-test-langchain4j-rag-bridge-ql4j']/pom:build/pom:plugins/pom:plugin[pom:artifactId='maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
            <!-- AllMiniLmL6V2EmbeddingModel loads a native .so via JNI; @TestProfile re-augmentation
                 creates a new classloader which cannot reload the same native library.
                 Mirrors the surefire config of the module in the camel-quarkus repository. -->
            <reuseForks>false</reuseForks>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/pom:project[./pom:artifactId/text() = 'camel-quarkus-integration-test-jdbc-grouped']/pom:build/pom:plugins/pom:plugin[pom:artifactId='maven-surefire-plugin']/pom:configuration">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
                <!-- The Oracle and DB2 dev service containers frequently fail to start within the startup
                     timeout on the CI runners. Their datasources point at dummy JDBC urls (see the
                     jdbc-grouped test entry in the root pom.xml) so the containers are never started.
                     See https://github.com/apache/camel-quarkus/issues/9048-->
                <excludes>
                    <exclude>**/CamelDb2JdbcTest.java</exclude>
                    <exclude>**/CamelOracleJdbcTest.java</exclude>
                </excludes>
            </xsl:copy>
      </xsl:template>

</xsl:stylesheet>
