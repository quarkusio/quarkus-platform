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
            <plugin>
                <groupId>io.fabric8</groupId>
                <artifactId>docker-maven-plugin</artifactId>
                <version>0.38.0</version>
                <configuration>
                    <images>
                        <image>
                            <name>localstack/localstack:0.13.1</name>
                            <alias>aws-local-stack</alias>
                            <run>
                                <env>
                                    <SERVICES>s3,dynamodb,sns,sqs,kms,ssm,ses,secretsmanager</SERVICES>
                                    <START_WEB>0</START_WEB>
                                </env>
                                <ports>
                                    <port>4566:4566</port>
                                </ports>
                                <log />
                                <wait>
                                    <time>30000</time>
                                    <log>^Ready\.$</log>
                                </wait>
                            </run>
                        </image>
                        <image>
￼                           <name>motoserver/moto:3.0.2</name>
￼                           <alias>aws-moto</alias>
￼                           <run>
￼                               <ports>
￼                                   <port>5000:5000</port>
￼                               </ports>
￼                               <log />
￼                               <wait>
￼                                   <time>30000</time>
￼                                   <log>^ \* Running on</log>
￼                               </wait>
￼                           </run>
￼                       </image>
                    </images>
                    <!--Stops all dynamodb images currently running, not just those we just started.
                      Useful to stop processes still running from a previously failed integration test run -->
                    <allContainers>true</allContainers>
                    <skip>${skipTests}</skip>
                </configuration>
                <executions>
                    <execution>
                        <id>docker-start</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>stop</goal>
                            <goal>start</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>docker-stop</id>
                        <phase>post-integration-test</phase>
                        <goals>
                            <goal>stop</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
