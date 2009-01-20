<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />
<xsl:template match="/list">
	<list>
		<xsl:copy-of select="*"/>
		<software-component>
			<name><xsl:value-of select="$name"/></name>
			<arch><xsl:value-of select="$arch"/></arch>
			<version><xsl:value-of select="$version"/></version>
		</software-component>
	</list>
</xsl:template>
</xsl:stylesheet>
