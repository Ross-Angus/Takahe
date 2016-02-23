<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/data/global.xml'>
]>
<!--
* * * * * * * * * * * * * * * * * * * * * * * * * * * *
* The above !ENTITYs are a bit like global variables, *
* in that you can use them wherever you like in the   *
* XSLT, to replace a string. They work like this:     *
* <!ENTITY example 'This is a string'>                *
* &example; => This is a string                       *
* This will also work for XPATHs:                     *
* <!ENTITY description '/page/meta/description'>      *
* &description; => /page/meta/description             *
* * * * * * * * * * * * * * * * * * * * * * * * * * * *
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" encoding="utf-8" indent="yes"/>
	<xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz-'"/>
	<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ '"/>
	<!-- A non-exhaustive list of characters which aren't the alphabet, or numbers. It's use for the FAQ template. -->
	<xsl:variable name="nonalphanum" select="'?#'"/>

	<!--
	* * * * * * * * * * * * * * * * * * *
	* Site title - used in the <head/>  *
	* * * * * * * * * * * * * * * * * * *
	-->
	<xsl:variable name="site-title">
		<xsl:choose>
			<xsl:when test="normalize-space(document('&global-path;')/global/meta/site-title) != ''">
				<xsl:value-of select="normalize-space(document('&global-path;')/global/meta/site-title)"/>
			</xsl:when>
			<xsl:otherwise>No site name found. Please add one to global.xml.</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!--
	* * * * * * * * * * * * * * * *
	* Top-level navigation links  *
	* * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="top-nav">
		<xsl:param name="url"/>
		<nav aria-label="{@title}" itemscope="" itemtype="https://schema.org/SiteNavigationElement">
			<xsl:if test="normalize-space(@class) != ''">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<ul>
				<!-- Just the top-level navigation -->
				<xsl:for-each select="link">
					<li>
						<xsl:call-template name="paternity-test">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="next-nav">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
							<xsl:with-param name="top-level">true</xsl:with-param>
						</xsl:call-template>
					</li>
				</xsl:for-each>
			</ul>
		</nav>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * *
	* Second-level mega-menu links and beyond *
	* * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link" name="next-nav">
		<xsl:param name="url"/>
		<xsl:param name="top-level"/>
		<xsl:param name="link-count" select="count(link)"/>
		<!-- Is there any child links to write out? -->
		<xsl:if test="link">
			<ul>
				<xsl:if test="$top-level = 'true'"><xsl:attribute name="class">mega-menu</xsl:attribute></xsl:if>
				<xsl:for-each select="link">
					<li>
						<xsl:if test="$top-level = 'true'"><xsl:attribute name="style">width: <xsl:value-of select="100 div $link-count"/>%</xsl:attribute></xsl:if>
						<xsl:call-template name="paternity-test">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="next-nav">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* Second-level navigation links within their own navigation bar *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="sub-nav">
		<xsl:param name="url"/>

			<!-- Top level links only -->
			<xsl:for-each select="link">
				<!-- We don't want to write out the top level links: this
				template is only intended to write out the second level
				links and downward. -->
				<xsl:if test="descendant-or-self::link[@url = $url]">
					<h2 class="h4"><xsl:value-of select="@text"/></h2>
					<xsl:call-template name="sub-nav">
						<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</xsl:for-each>

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * *
	* Lower levels of navigation for the sub-nav. *
	* Called recursively.                         *
	* * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link" name="sub-nav">
		<xsl:param name="url"/>
		<ul>
			<xsl:for-each select="link">
				<li>
					<xsl:call-template name="paternity-test">
						<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
					</xsl:call-template>
					<!-- If we're in the second level of navigation, only write out the third
					level if the current page appear inside it. -->
					<xsl:if test="count(ancestor::*) &gt; 2 and descendant-or-self::link[@url = $url]">
						<xsl:call-template name="sub-nav">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
					</xsl:if>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * *
	* This handles the state of individual links  *
	* in the main and sub navigation.             *
	* * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="link" name="paternity-test">
    	<xsl:param name="url"/>
    	<xsl:choose>
    		<!-- When we are on the current page, because recursive links are a bad idea. No, really. -->
    		<xsl:when test="@url = $url">
    			<em title="You are here"><xsl:value-of select="@text"/></em>
    		</xsl:when>
    		<!-- When the current page is a child of the current node -->
    		<xsl:when test="descendant::link[@url = $url]">
    			<em><xsl:apply-templates select="."/></em>
    		</xsl:when>
    		<!-- Normal link -->
    		<xsl:otherwise>
				<xsl:apply-templates select="."/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * *
	* Outermost template for the crumbtrail *
	* * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="crumb-trail">
		<xsl:param name="url"/>
		<!-- The apply-templates which calls this pulls in *all* <nav/> elements (there can
		be more than one). To avoid duplicate crumbtrails, we'll only write out the
		crumbtrail if the current URL appears in it. This means that no crumbtrail will
		be output, if the current URL doesn't exactly match one in global.xml. -->
		<xsl:if test=".//link/@url = $url">
			<nav aria-label="Crumbtrail" itemscope="" itemtype="https://schema.org/breadcrumb">
				<ol itemscope="" itemtype="https://schema.org/BreadcrumbList">
					<!--
					The below if statement ensure that a "Home" link appears as the first
					link in the crumbtrail, if you're not on the home page. If you *are*
					on the home page, the home node is pulled from the navigation XML,
					so it gets all the attributes.
					In this example, the home link is a sibling of the top-level navigation.
					This isn't the pure way of doing this, where every top-level page would
					be a child of home, but it's also something which happens often enough
					for the below code to be useful.
					If you're doing a pure navigation, then the below if statement should
					not be required. -->
					<xsl:if test="$url != //link[@text = 'Home']/@url">
						<li><xsl:apply-templates select="//link[@text = 'Home']"/></li>
					</xsl:if>

					<xsl:apply-templates mode="crumb-list-item">
						<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
					</xsl:apply-templates>
				</ol>
			</nav>
		</xsl:if>
	</xsl:template>

	<!-- An individual list item in the crumb trail -->
	<xsl:template match="link" mode="crumb-list-item">
		<xsl:param name="url"/>
		<xsl:choose>

			<!-- Normal link: appears above the current page in the navigation -->
			<xsl:when test="descendant::link[@url = $url]">
				<li itemprop="itemListElement" itemscope="" itemtype="http://schema.org/ListItem">
					<xsl:apply-templates select="."/>
				</li>

				<!-- Call next level of nav. It selects <link/> to exclude tags from the crumbtrail. -->
				<xsl:apply-templates mode="crumb-list-item" select="link">
					<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
				</xsl:apply-templates>

			</xsl:when>

			<!-- Final node in the crumbtrail: the current page -->
			<xsl:when test="@url = $url">
				<li itemprop="itemListElement" itemscope="" itemtype="http://schema.org/ListItem">
					<em title="You are here" itemprop="name">
						<xsl:value-of select="@text"/>
					</em>
				</li>
			</xsl:when>

		</xsl:choose>

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* Just anchor tags and all their attributes *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link">
		<a>
			<xsl:if test="normalize-space(@url) != ''">
				<xsl:attribute name="itemprop">url</xsl:attribute>
				<xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@target) != ''">
				<xsl:attribute name="target"><xsl:value-of select="@target"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@onclick) != ''">
				<xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@class) != ''">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@id) != ''">
				<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@text) != ''">
				<span itemprop="name"><xsl:value-of select="@text"/></span>
			</xsl:if>
		</a>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * *
	* The language attribute, on the <html/> element  *
	* * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="meta" mode="lang">
		<xsl:attribute name="lang">
			<xsl:choose>
				<!-- Is there a language attribute in this page file? -->
				<xsl:when test="normalize-space(language) != ''">
					<xsl:value-of select="normalize-space(language)"/>
				</xsl:when>
				<!-- Pull the language from the global file -->
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(document('&global-path;')/global/meta/language)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This finds the current page in the navigation, then writes out a list of tags *
	* associated with that page in global.xml.                                      *
	* Each one of those tags is a link. When the user clicks on one of these links, *
	* they will see a list of pages which also shares that tag.                     *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link" mode="tagging">
		<xsl:param name="url"/>
		<xsl:if test="@url = $url">
			<nav aria-label="Tags">
				<h1 class="h4">Tags</h1>
				<xsl:choose>
					<xsl:when test="count(tag) &gt; 0">
						<ul>
							<!-- Each tag on the current page -->
							<xsl:for-each select="tag">
								<!-- Take the <tag/> value. Make it lower-case. Remove all the mad white space. Replace remaining spaces with hyphens. -->
								<li>
									<label for="tag-{translate(normalize-space(translate(.,$upper,$lower)),' ','-')}"><xsl:value-of select="."/></label>
									<input type="checkbox" id="tag-{translate(normalize-space(translate(.,$upper,$lower)),' ','-')}" class="toggle"/>
									<section class="details">
										<h2 class="h4">Other pages which use the <q><xsl:value-of select="normalize-space(.)"/></q> tag</h2>
										<xsl:choose>
											<xsl:when test="count(//tag[text() = current()]) &gt; 1">
												<ul>
													<!-- All links from the navigation which aren't the current page, and have at least one tag. -->
													<xsl:apply-templates mode="tag-links" select="//link[not(@url = $url) and tag]">
														<xsl:with-param name="tag"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
													</xsl:apply-templates>
												</ul>
											</xsl:when>
											<xsl:otherwise>
												<p>No other pages share this tag.</p>
											</xsl:otherwise>
										</xsl:choose>
									</section>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p>This page does not have any tags.</p>
					</xsl:otherwise>
				</xsl:choose>
			</nav>

		</xsl:if>
	</xsl:template>

	<!-- This finds other <link/> nodes with matching tags to whatever is passed into it. -->
	<xsl:template match="link" mode="tag-links">
		<xsl:param name="tag"/>
		<xsl:param name="url"><xsl:value-of select="@url"/></xsl:param>
		<xsl:param name="text"><xsl:value-of select="@text"/></xsl:param>
		<xsl:for-each select="tag">
			<xsl:if test="normalize-space(.) = $tag">
				<li><a href="{$url}"><xsl:value-of select="$text"/></a></li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--
	* * * * * * * * * * * *
	* Meta and title tags *
	* * * * * * * * * * * *
	-->
	<xsl:template match="meta" mode="meta">
		<xsl:param name="url"/>

		<xsl:variable name="site-title" select="document('&global-path;')/global/meta/site-title"/>
		<xsl:variable name="page-title">
			<xsl:choose>
				<!-- Do we have a page title in the page XML file? -->
				<xsl:when test="normalize-space(title) != ''">
					<xsl:value-of select="title"/>
				</xsl:when>
				<!-- Otherwise get it from the navigation XML -->
				<xsl:otherwise>
					<xsl:value-of select="document('&global-path;')//link[@url = $url]/@text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<title>
			<xsl:value-of select="$page-title"/>
			<!-- Does the site itself have a title? Is it different to the current page title? -->
			<xsl:if test="normalize-space($site-title) != '' and normalize-space($site-title) != normalize-space($page-title)">
				 - <xsl:value-of select="normalize-space($site-title)"/>
			</xsl:if>
		</title>

		<!-- Description - used in multiple places -->
		<xsl:variable name="description">
			<xsl:choose>
				<!-- Does the description node exist in the page level xml?
				Note that it's valid for this node to exist and be blank -
				this means that no description should be displayed. -->
				<xsl:when test="normalize-space(description) != ''"><xsl:value-of select="description"/></xsl:when>
				<!-- Does global.xml have a description? -->
				<xsl:when test="normalize-space(document('&global-path;')/global/meta/description) != ''">
					<xsl:value-of select="document('&global-path;')/global/meta/description"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<!-- You don't *have* to add a description -->
		<xsl:if test="normalize-space($description) != ''">
			<meta name="description" content="{$description}"/>
			<meta property="og:description" content="{$description}"/>
		</xsl:if>

		<xsl:if test="normalize-space($page-title) != ''">
			<meta property="og:title" content="{$page-title}"/>
		</xsl:if>

		<xsl:variable name="base-url">
			<xsl:if test="normalize-space(document('&global-path;')/global/meta/base-url) != ''">
				<xsl:value-of select="document('&global-path;')/global/meta/base-url"/>
			</xsl:if>
		</xsl:variable>

		<xsl:if test="normalize-space(document('&global-path;')/global/meta/open-graph-type) != ''">
			<meta property="og:type" content="{normalize-space(document('&global-path;')/global/meta/open-graph-type)}"/>
		</xsl:if>

		<xsl:if test="normalize-space($base-url) != ''">
			<meta property="og:url">
				<xsl:attribute name="content">
					<!-- From the global variables -->
					<xsl:value-of select="$base-url"/>
					<!-- From the local file -->
					<xsl:value-of select="path"/>
				</xsl:attribute>
			</meta>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/site-image) != ''">
			<meta property="og:image" content="{$base-url}{normalize-space(document('&global-path;')/global/meta/site-image)}"/>
		</xsl:if>
		<xsl:if test="normalize-space($site-title) != ''">
			<meta property="og:site_name" content="{$site-title}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/facebook-id) != ''">
			<meta property="fb:admins" content="{normalize-space(document('&global-path;')/global/meta/facebook-id)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/charset) != ''">
			<meta charset="{normalize-space(document('&global-path;')/global/meta/charset)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/viewport) != ''">
			<meta name="viewport" content="{normalize-space(document('&global-path;')/global/meta/viewport)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/X-UA-Compatible) != ''">
			<meta http-equiv="X-UA-Compatible" content="{normalize-space(document('&global-path;')/global/meta/X-UA-Compatible)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/HandheldFriendly) != ''">
			<meta name="HandheldFriendly" content="{normalize-space(document('&global-path;')/global/meta/HandheldFriendly)}"/>
		</xsl:if>

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This is used to copy content from the original XML. This    *
	* output is then passed to any of the templates below which   *
	* have a mode of "content", so that custom tags can be        *
	* intercepted, then replaced. For more information, see:      *
	* http://www.xmlplease.com/xsltidentity                       *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="@*|node()" mode="content">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="content"/>
		</xsl:copy>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <youtube id="[YouTube id]"/>  *
	* and replaces it with proper markup.                         *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="youtube" mode="content">
		<iframe width="900" height="506" src="https://www.youtube.com/embed/{@id}" frameborder="0" allowfullscreen=""></iframe>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <note/>     *
	* and replaces it with proper markup.       *
	* The <note/> tag can include markup, but   *
	* is happier with inline tags, rather than  *
	* headings and paragraphs. The text value   *
	* of the note is replicated in the title    *
	* attribute, for older browsers.            *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="note" mode="content">
    	<sup title="{.}">
			<label for="note{position()}">&#10054;</label>
			<input type="checkbox" id="note{position()}" class="toggle"/>
			<span class="details"><xsl:apply-templates select="@*|node()" mode="content"/></span>
		</sup>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This takes the question and answer set from the XML and builds up a series of jump-links  *
	* and some show/hide questions and answers.                                                 *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="faqs" mode="content">
    	<section class="faq">
    		<header>
    			<ul>
	    			<xsl:for-each select="faq/question">
	    				<li>
	    					<a href="#{translate(translate(normalize-space(.),$upper,$lower),$nonalphanum,'')}">
	    						<xsl:apply-templates select="node()" mode="content"/>
	    					</a>
	    				</li>
	    			</xsl:for-each>
	    		</ul>
    		</header>
    		<article>
    			<xsl:for-each select="faq">
	    			<section id="{translate(translate(normalize-space(question),$upper,$lower),$nonalphanum,'')}" itemscope="" itemtype="http://schema.org/Question">
						<h1 class="h3">
							<label for="answer{position()}" itemprop="text">
								<xsl:apply-templates select="question/node()" mode="content"/>
							</label>
						</h1>
						<input type="checkbox" id="answer{position()}" class="toggle"/>
						<!-- This assumes that there will only be inline HTML in the XML.
						You may need block elements in there too. -->
						<p class="details" itemprop="suggestedAnswer">
							<xsl:apply-templates select="answer/node()" mode="content"/>
						</p>
					</section>
				</xsl:for-each>
			</article>
		</section>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <jargon type="HTML"/> and *
	* supplies the correct <abbr/> markup for it.             *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="jargon" mode="content">
    	<!-- The user can type in <jargon type="HTML"/> or <jargon type="html"/>, or any mix of the two.
    	Note that the case used in the type attribute will be output unchanged into the page. -->
    	<xsl:variable name="type"><xsl:value-of select="translate(@type,$lower,$upper)"/></xsl:variable>
    	<!-- This tracks how many jargon tags of each type are on the page. -->
    	<xsl:variable name="jargon-order"><xsl:number count="jargon[@type = $type]" level="any"/></xsl:variable>
		<abbr>
			<!-- Best practice suggests that for the benefit of speech browsers, only the first
			instance of a particular <abbr/> should have the abbreviation spelt out to the user.
			After that point, having the string wrapped in an <abbr/> will stop the speech
			browser from trying to pronounce the string out loud. -->
			<xsl:if test="$jargon-order = 1">
				<xsl:attribute name="title">
					<xsl:choose>
						<xsl:when test="$type = 'HTML'">HyperText Markup Language</xsl:when>
						<xsl:when test="$type = 'XHTML'">Extensible Hypertext Markup Language</xsl:when>
						<xsl:when test="$type = 'CSS'">Cascading Style Sheet</xsl:when>
						<xsl:when test="$type = 'XSLT'">Extensible Stylesheet Language Transformations</xsl:when>
						<xsl:when test="$type = 'XML'">Extensible Markup Language</xsl:when>
						<xsl:when test="$type = 'HTTP'">HyperText Transfer Protocol</xsl:when>
						<xsl:when test="$type = 'URI'">Uniform Resource Identifier</xsl:when>
						<xsl:when test="$type = 'URL'">Uniform Resource Locator</xsl:when>
						<xsl:when test="$type = 'ISO'">International Organization for Standardization</xsl:when>
						<xsl:when test="$type = 'IE'">Internet Explorer</xsl:when>
						<xsl:when test="$type = 'SEO'">Search Engine Optimisation</xsl:when>
						<xsl:when test="$type = 'CMS'">Content Management System</xsl:when>
						<xsl:when test="$type = 'MIT'">Massachusetts Institute of Technology</xsl:when>
						<xsl:when test="$type = 'CDN'">Content Delivery Network</xsl:when>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="@type"/>
		</abbr>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* Because the HTML is not entitised in the XML, this template entitises it, so it can *
	* be seen inside a <pre/> tag. You can use it like this:                              *
	* <pre><code class="html"><xsl:apply-templates mode="verb" select="."/></code></pre>  *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="*|@*" mode="verb">
        <xsl:variable name="node-type">
            <xsl:call-template name="node-type"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$node-type='element'"> <!-- element -->
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:apply-templates select="@*" mode="verb"/>
                <xsl:text>&gt;</xsl:text>
                <xsl:apply-templates mode="verb"/>
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:when>
            <xsl:when test="$node-type='text'"> <!-- text -->
                <xsl:value-of select="self::text()"/>
            </xsl:when>
            <xsl:when test="$node-type='attribute'"> <!--any attribute-->
                <xsl:text> </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>="</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="node-type">
        <xsl:param name="node" select="."/>
        <xsl:apply-templates mode="nodetype" select="$node"/>
    </xsl:template>
    <xsl:template mode="nodetype" match="*">element</xsl:template>
    <xsl:template mode="nodetype" match="@*">attribute</xsl:template>
    <xsl:template mode="nodetype" match="text()">text</xsl:template>

</xsl:stylesheet>