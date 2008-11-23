<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" />

<xsl:template match="test">
	<!-- PLANNER -->
	<xsl:text>PLANNER=1</xsl:text>

	<!-- TEST_NAME -->
	<xsl:text> TEST_NAME=</xsl:text>
	<xsl:value-of select="@id" />

	<!-- Process each test's variables -->
	<xsl:for-each select="var">
		<xsl:text> </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:text>="</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>"</xsl:text>
	</xsl:for-each>

	<!-- run_test -->
	<xsl:text> run_test </xsl:text>
	<xsl:value-of select="@type" />

	<xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="text()" />
</xsl:stylesheet>
