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

    
    

    <!-- Formatting dc.date.issued -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field/text()">
        <xsl:call-template name="formatdate">
            <xsl:with-param name="datestr" select="." />
        </xsl:call-template>
    </xsl:template>

    <!-- Mapping dc.language.iso from ISO 639-1 to 639-3 -->
    <xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field/text()">
        <xsl:call-template name="getThreeLetterCodeLanguage">
            <xsl:with-param name="lang2" select="." />
        </xsl:call-template>
    </xsl:template>
	
    <!-- Date format -->
    <xsl:template name="formatdate">
        <xsl:param name="datestr" />
        <xsl:variable name="sub">
            <xsl:value-of select="substring($datestr,1,10)" />
        </xsl:variable>
        <xsl:value-of select="$sub" />
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
  
  
  <!-- Calculates the total size of original bitstreams recursively--> 
    <xsl:template match="/doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
        <xsl:call-template name="calculateBitstremsTotalSize">
            <xsl:with-param name="totalSize" select="0"/>
            <xsl:with-param name="currentBitstreamPosition" select="1"/>
            <xsl:with-param name="bitstreamsTotalNumber" select="count(../doc:element[@name='bitstreams']/doc:element[@name='bitstream'])"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="calculateBitstremsTotalSize">
        <xsl:param name="totalSize"/>
        <xsl:param name="currentBitstreamPosition"/>
        <xsl:param name="bitstreamsTotalNumber"/>
        <xsl:choose>
            <xsl:when test="$currentBitstreamPosition &lt;= $bitstreamsTotalNumber">
                <xsl:variable name="currentBitstreamSize" select="../doc:element[@name='bitstreams']/doc:element[@name='bitstream' and position() = $currentBitstreamPosition]/doc:field[@name='size']/text()"/>
                <xsl:call-template name="calculateBitstremsTotalSize">
                    <xsl:with-param name="totalSize" select="$totalSize + $currentBitstreamSize"/>
                    <xsl:with-param name="currentBitstreamPosition" select="$currentBitstreamPosition + 1"/>
                    <xsl:with-param name="bitstreamsTotalNumber" select="$bitstreamsTotalNumber"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/> 
                    <xsl:element name="field" namespace="http://www.lyncode.com/xoai">
                        <xsl:attribute name="name">size</xsl:attribute>
                        <!-- The size is in bytes therefore a conversion is needed --> 
                        <xsl:choose>
                            <xsl:when test="$totalSize &lt; 1024">
                                <xsl:value-of select="concat($totalSize, ' B')"/>
                            </xsl:when>
                            <xsl:when test="$totalSize &lt; 1024 * 1024">
                                <xsl:value-of select="concat(substring(string($totalSize div 1024),1,5), ' kB')"/>
                            </xsl:when>
                            <xsl:when test="$totalSize &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="concat(substring(string($totalSize div (1024 * 1024)),1,5), ' MB')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(substring(string($totalSize div (1024 * 1024 * 1024)),1,5), ' GB')"/>
                            </xsl:otherwise>
                        </xsl:choose> 
                    </xsl:element>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
       
    <!-- AUXILIARY TEMPLATES -->
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
</xsl:stylesheet>
