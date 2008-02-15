<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns="http://www.w3.org/1999/xhtml">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
	<list>
	<xsl:apply-templates/>
	</list>
</xsl:template>

<xsl:template match="//node[description='VGA compatible controller']">
	<component>
		<type>Video</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
	</component>
</xsl:template>

<xsl:template match="//node[description='Ethernet interface']">
	<component>
		<type>NIC</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
		<serial><xsl:value-of select="serial"/></serial>
	</component>
</xsl:template>

<xsl:template match="//node[description='FireWire (IEEE 1394)']">
	<component>
		<type>Fire Wire</type>
		<vendor><xsl:value-of select="vendor"/></vendor>
		<model><xsl:value-of select="product"/></model>
	</component>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
