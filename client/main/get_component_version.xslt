<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="text" />

<xsl:template match='//component'>
	<xsl:if test='type = $group'>
		<xsl:value-of select="version" />
	</xsl:if>
</xsl:template>

<xsl:template match="text()" />
</xsl:stylesheet>
