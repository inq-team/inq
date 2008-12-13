<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:components="http://www.w3.org/1999/xhtml">

<xsl:output method="xml" indent="yes" />

<xsl:template match="components:list">
	<xsl:element name="list" namespace="http://www.w3.org/1999/xhtml">
		<xsl:for-each select="./components:component">
			<xsl:element name="component">
				<xsl:for-each select="./*">
					<xsl:element name="{name(.)}">
						<xsl:value-of select="." />
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:for-each>

		<xsl:element name="component">
			<xsl:element name="type"><xsl:value-of select="$type" /></xsl:element>
			<xsl:element name="vendor"><xsl:value-of select="$vendor" /></xsl:element>
			<xsl:element name="model"><xsl:value-of select="$model" /></xsl:element>
			<xsl:element name="serial"><xsl:value-of select="$serial" /></xsl:element>
			<xsl:element name="version"><xsl:value-of select="$version" /></xsl:element>
		</xsl:element>
	</xsl:element>
</xsl:template>

</xsl:stylesheet>
