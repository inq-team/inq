<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="text" />

<xsl:template match='tests'>
	<xsl:text>&quot;</xsl:text>
		<xsl:value-of select="@name" />
	<xsl:text>&quot;&#10;</xsl:text>

	<xsl:text>&quot;</xsl:text>
		<xsl:value-of select="description" />
	<xsl:text>&quot;&#10;</xsl:text>

	<xsl:text>&quot;</xsl:text>
		<xsl:value-of select="warning" />
	<xsl:text>&quot;&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
