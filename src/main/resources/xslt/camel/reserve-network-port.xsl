<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pom="http://maven.apache.org/POM/4.0.0"
  xmlns="http://maven.apache.org/POM/4.0.0">

  <xsl:output method="xml" indent="yes"/>
  <!--xsl:strip-space elements="*"/-->

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/pom:project/pom:build/pom:plugins/pom:plugin[1]">
    <xsl:element name="plugin">
        <xsl:element name="groupId">org.codehaus.mojo</xsl:element>
        <xsl:element name="artifactId">build-helper-maven-plugin</xsl:element>
        <xsl:element name="executions">
            <xsl:element name="execution">
                <xsl:element name="id">reserve-network-port</xsl:element>
                <xsl:element name="goals">
                    <xsl:element name="goal">reserve-network-port</xsl:element>
                </xsl:element>
                <xsl:element name="phase">process-test-resources</xsl:element>
                <xsl:element name="configuration">
                    <xsl:element name="portNames">
                        <xsl:element name="portName">test.http.port.jvm</xsl:element>
                        <xsl:element name="portName">test.https.port.jvm</xsl:element>
                        <xsl:element name="portName">test.http.port.native</xsl:element>
                        <xsl:element name="portName">test.https.port.native</xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:element>
    <xsl:copy-of select="."/>
  </xsl:template>
</xsl:stylesheet>
