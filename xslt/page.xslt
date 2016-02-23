<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/data/global.xml'>
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="global-templates.xslt"/>
	<xsl:output method="html" encoding="utf-8" indent="yes"/>

	<xsl:template match="/">
		<html itemscope="" itemtype="http://schema.org/WebPage" class="no-js">
			<xsl:apply-templates select="/page/meta" mode="lang"/>
			<head>
				<xsl:apply-templates select="/page/meta" mode="meta">
					<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
				</xsl:apply-templates>
				<link rel="stylesheet" href="/css/main.css"/>
				<link rel="stylesheet" href="/css/monokai-sublime.css"/>
				<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/8.9.1/highlight.min.js"></script>
				<script>hljs.initHighlightingOnLoad();</script>
				<!--[if lt IE 9]>
				<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
				<script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
				<![endif]-->
			</head>

			<body>

				<p class="logo-takahe" title="Takahē client-side XSLT Framework"><i class="sr-only">Takahē client-side XSLT Framework</i></p>

				<!-- Top navigation -->
				<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="top-nav">
					<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
				</xsl:apply-templates>

				<!-- Crumbtrail -->
				<xsl:apply-templates select="document('&global-path;')/global/nav" mode="crumb-trail">
					<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
				</xsl:apply-templates>

				<main>
					<xsl:apply-templates select="/page/content[@type = 'main']/node()" mode="content"/>
				</main>

				<aside>
					<!-- Sub-navigation -->
					<nav aria-label="Sub-navigation" itemscope="" itemtype="https://schema.org/SiteNavigationElement">
						<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="sub-nav">
							<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
						</xsl:apply-templates>
					</nav>

					<!-- Tagging -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']//link" mode="tagging">
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>
					<xsl:value-of select="''"/>
				</aside>

				<footer>
					<!-- Footer navigation -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'footer']" mode="top-nav">
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>
					<p><strong>XSLT version:</strong><xsl:text> </xsl:text><xsl:value-of select="system-property('xsl:version')"/> |
					<strong>XSLT vendor:</strong><xsl:text> </xsl:text><xsl:value-of select="system-property('xsl:vendor')"/> |
					<strong>XSLT vendor URL:</strong><xsl:text> </xsl:text><xsl:value-of select="system-property('xsl:vendor-url')"/></p>
				</footer>

			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>