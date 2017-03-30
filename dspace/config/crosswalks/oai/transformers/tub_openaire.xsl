<?xml version="1.0" encoding="UTF-8"?>
<!-- 

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

	Developed by DSpace @ Lyncode <dspace@lyncode.com> 
	Following OpenAIRE Guidelines 1.1:
		- http://www.openaire.eu/component/content/article/207

 -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://www.lyncode.com/xoai">

	<xsl:include href="embargo_selector.xsl" />
	<xsl:include href="../templates/tub_templates.xsl" />

	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>

    <!-- dc.title, concatenated with dc.title.subtitle, if available -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field/text()">
        <xsl:choose>
            <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
                <xsl:choose>
                    <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']">
                        <xsl:value-of select="concat(/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value'],':',/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value'])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Remove dc.title.subtitle -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']" />

    <!-- dc.title.translated, concatenated with dc.title.translatedsubtitle, if available -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field/text()">
        <xsl:choose>
            <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field[@name='value']">
                <xsl:choose>
                    <xsl:when test="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translatedsubtitle']/doc:element/doc:field[@name='value']">
                        <xsl:value-of select="concat(/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field[@name='value'],':',/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translatedsubtitle']/doc:element/doc:field[@name='value'])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field[@name='value']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Remove dc.title.translatedsubtitle -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translatedsubtitle']" />

    <!-- Formatting dc.subject DDC -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='ddc']/doc:element/doc:field/text()">
		<xsl:variable name="ddc">
			<xsl:call-template name="find-ddc-recursively">
				<xsl:with-param name="text" select="."/>
				<xsl:with-param name="mode" select="'number'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$ddc">
			<xsl:call-template name="addPrefix">
				<xsl:with-param name="value" select="$ddc"/>
				<xsl:with-param name="prefix" select="'info:eu-repo/classification/ddc/'"></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
    <!-- Remove other dc.subject.* -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name!='ddc']"/>

	<!-- Formatting dc.date.issued -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field/text()">
		<xsl:call-template name="formatdate">
			<xsl:with-param name="datestr" select="." />
		</xsl:call-template>
	</xsl:template>

	<!-- Removing other dc.date.* -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued']" />

	<!-- Prefixing and and Modifying dc.type - Types not in the list are deleted!-->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="contains(., 'Article')">
				<xsl:text>info:eu-repo/semantics/article</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'Book Part')">
				<xsl:text>info:eu-repo/semantics/bookPart</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'Book')">
				<xsl:text>info:eu-repo/semantics/book</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'Conference Object')">
				<xsl:text>info:eu-repo/semantics/conferenceObject</xsl:text>
			</xsl:when>
            <xsl:when test="contains(., 'Conference Proceedings')">
                <xsl:text>info:eu-repo/semantics/conferenceObject</xsl:text>
            </xsl:when>
			<xsl:when test="contains(., 'Doctoral Thesis')">
				<xsl:text>info:eu-repo/semantics/doctoralThesis</xsl:text>
			</xsl:when>
            <xsl:when test="contains(., 'Habilitation')">
                <xsl:text>info:eu-repo/semantics/doctoralThesis</xsl:text>
            </xsl:when>
			<xsl:when test="contains(., 'Master Thesis')">
				<xsl:text>info:eu-repo/semantics/masterThesis</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'Periodical Part')">
				<xsl:text>info:eu-repo/semantics/contributionToPeriodical</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'Preprint')">
				<xsl:text>info:eu-repo/semantics/preprint</xsl:text>
			</xsl:when>
            <xsl:when test="contains(., 'Report')">
                <xsl:text>info:eu-repo/semantics/report</xsl:text>
            </xsl:when>
            <xsl:when test="contains(., 'Research Paper')">
                <xsl:text>info:eu-repo/semantics/workingPaper</xsl:text>
            </xsl:when>
			<xsl:when test="contains(., 'Other')">
				<xsl:text>info:eu-repo/semantics/other</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Prefixing dc.type.version -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field/text()">
		<xsl:call-template name="addPrefix">
			<xsl:with-param name="value" select="." />
			<xsl:with-param name="prefix" select="'info:eu-repo/semantics/'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Prefixing dc.description.sponsorship for EU projects -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="starts-with(., 'EC')">
				<xsl:call-template name="addPrefix">
					<xsl:with-param name="value" select="." />
					<xsl:with-param name="prefix" select="'info:eu-repo/grantAgreement/'"></xsl:with-param>
				</xsl:call-template>
			</xsl:when>
     	</xsl:choose>
	</xsl:template>

	<!-- Mapping dc.language.iso from ISO 639-1 to 639-3 -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field/text()">
		<xsl:call-template name="getThreeLetterCodeLanguage">
			<xsl:with-param name="lang2" select="." />
		</xsl:call-template>
	</xsl:template>

	<!-- Remove other dc.publisher -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']"/>
    <!-- Remove other dc.publisher.* -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element"/>

    <!-- AUXILIARY TEMPLATES -->
	
	<!-- dc.type prefixing -->
	<xsl:template name="addPrefix">
		<xsl:param name="value" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="starts-with($value, $prefix)">
				<xsl:value-of select="$value" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($prefix, $value)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Date format -->
	<xsl:template name="formatdate">
		<xsl:param name="datestr" />
		<xsl:variable name="sub">
			<xsl:value-of select="substring($datestr,1,10)" />
		</xsl:variable>
		<xsl:value-of select="$sub" />
	</xsl:template>
</xsl:stylesheet>
