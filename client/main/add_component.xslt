<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />
<xsl:template match="/list">
	<list>
		<xsl:copy-of select="*"/>
		<component>
			<type><xsl:value-of select="$type"/></type>
			<vendor><xsl:value-of select="$vendor"/></vendor>
			<model><xsl:value-of select="$model"/></model>
			<serial><xsl:value-of select="$serial"/></serial>
			<version><xsl:value-of select="$version"/></version>
		</component>
	</list>
</xsl:template>
</xsl:stylesheet>
