<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
	<list>
	<xsl:apply-templates/>
	</list>
</xsl:template>

<xsl:template match="//node[@class='processor']">
	<component>
		<type>CPU</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
	</component>
</xsl:template>

<xsl:template match="//node[@class='display']">
	<component>
		<type>Video</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
	</component>
</xsl:template>

<xsl:template match="//node[@class='network']">
	<component>
		<type>NIC</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
		<serial><xsl:value-of select="serial"/></serial>
	</component>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
