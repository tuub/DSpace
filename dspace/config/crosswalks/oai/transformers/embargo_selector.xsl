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
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:date="http://exslt.org/dates-and-times"
	extension-element-prefixes="date">

	<!--
		Select here which field under /doc:metadata/doc:element[@name='others'] you wish to use as the embargo end date.
		Options: bitstreamMinEmbargoEnd, bitstreamMaxEmbargoEnd, itemEmbargoEnd
	 -->
	<xsl:variable name="embargoField" select="'bitstreamMaxEmbargoEnd'"/>

	<!-- Changes the embargo end date attribute we wish to use to 'embargoEnd' - this is the field that is matched in oai_dc -->
	<xsl:template match="/doc:metadata/doc:element[@name='others']/doc:field/@name[.=$embargoField]">
		<xsl:attribute name="name">
			<xsl:value-of select="'embargoEnd'"/>
		</xsl:attribute>
	</xsl:template>

	<!--
		If the embargo end date is in the future, a new field /doc:metadata/doc:element[@name='others']/doc:field[@name=embargo]
		is created and given the value 'embargoedAcces' (for OpenAire)
	-->
	<xsl:template match="/doc:metadata/doc:element[@name='others']">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
			<xsl:variable name="embargo">
				<xsl:call-template name="isDateAfterToday">
					<xsl:with-param name="date" select="doc:field[@name=$embargoField]/text()"/>
				</xsl:call-template>
			</xsl:variable>
				<xsl:element name="field" namespace="http://www.lyncode.com/xoai">
					<xsl:attribute name="name">openAireAccess</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$embargo = 'true'">info:eu-repo/semantics/embargoedAccess</xsl:when>
						<xsl:otherwise>info:eu-repo/semantics/openAccess</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="isDateAfterToday">
		<xsl:param name="date"/>
		<xsl:variable name="today" select="translate(substring-before(date:date-time(), 'T'), '-', '')"/>
		<xsl:variable name="dateAsNumber" select="translate($date, '-', '')"/>
		<xsl:if test="$dateAsNumber &gt; $today">
			<xsl:value-of select="true()"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
