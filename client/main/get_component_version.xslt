<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:components='http://www.w3.org/1999/xhtml'>

<xsl:output method="text" />

<xsl:template match='components:component'>
	<xsl:if test='components:type = $group'>
		<xsl:value-of select="components:version" />
		<xsl:text>&#10;</xsl:text>
	</xsl:if>
</xsl:template>

<xsl:template match="text()" />
</xsl:stylesheet>
