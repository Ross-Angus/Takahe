<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/data/global.xml'>
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="global-templates.xslt"/>
	<xsl:output method="xml" encoding="utf-8" indent="yes"/>

	<xsl:template match="/">
		<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
			<!-- It seems that adding a namespace is forbidden. Perhaps it will just work without it!
			<xsl:attribute name="xmlns">http://www.sitemaps.org/schemas/sitemap/0.9</xsl:attribute>
			-->
			<xsl:apply-templates select="document('&global-path;')//link"/>
		</urlset>
	</xsl:template>

	<xsl:template match="link">
		<url>
			<loc><xsl:value-of select="base-url"/><xsl:value-of select="@url"/></loc>
			<!-- This is a little crude, but how deep the page is in the navigation is used as a measure of how important it is.
			Another way to handle this would be to add in a new attribute into the navigation, to allow this figure to be overruled. -->
			<priority><xsl:value-of select="1 div (count(ancestor::*) - 1)"/></priority>
		</url>
	</xsl:template>

</xsl:stylesheet>