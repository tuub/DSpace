<?xml version="1.0" encoding="utf-8"?>  

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:mods="http://www.loc.gov/mods/v3"
    version="1.0">
    
   
    
    <xsl:template match="text()">
        <dim:dim>
            <xsl:apply-templates/>  
        </dim:dim>
    </xsl:template>
    
    
    <!--   mods:/abstract   ====>   dc.description.abstract   -->
    <xsl:template match="mods:mods/mods:abstract">
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute>
            <xsl:attribute name="element">description</xsl:attribute>
            <xsl:attribute name="qualifier">abstract</xsl:attribute> 
            <xsl:attribute name="lang">
                <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    
    <!--   mods:/accessCondition[@type="use and reproduction"] ====>   dc.rights  -->
    <xsl:template match="mods:mods/mods:accessCondition[@type='use and reproduction']">
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute> 
            <xsl:attribute name="element">rights</xsl:attribute> 
            <xsl:if test="@description ='uri'"> 
                <xsl:attribute name="qualifier">uri</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    
    
    <!--   mods:/genre ====>   dc.type  -->
    <xsl:template match="mods:mods/mods:genre[.='journal article']">
        <dim:field mdschema="dc" element="type">
            Article
        </dim:field>
    </xsl:template>   
    
    
    <!--   mods:/identifier[@type="doi"] ====>   dcterms.bibliographicCitation.doi, dc.identifier.pmid   -->
    <xsl:template match="mods:mods/mods:identifier[@type='doi'] |
                         mods:mods/mods:identifier[@type='pmid']">
        <xsl:choose>
            <xsl:when test="@type ='doi'"> <!--  or @type ='uri' or @type ='urn'-->
                <!--  dcterms.bibliographicCitation.doi -->
                <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="doi">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:when>
            <!--  dc.identifier.pmid -->
            <xsl:otherwise>
                <xsl:element name="dim:field">
                    <xsl:attribute name="mdschema">dc</xsl:attribute>
                    <xsl:attribute name="element">identifier</xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
                <xsl:attribute name="qualifier">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!--   mods:/language/languageTerm ====>   dc.language.iso  -->
    <xsl:template match="mods:mods/mods:language">
        <dim:field mdschema="dc" element="language" qualifier="iso">
                <xsl:value-of select="translate(mods:languageTerm,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
        </dim:field>
    </xsl:template>    
    
    
    <!--   mods:/note[@type='funding'] ====>   dc.description.sponsorship  -->
    <xsl:template match="mods:mods/mods:note[@type='funding']">
        <dim:field mdschema="dc" element="description" qualifier="sponsorship">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
    
    
    <!--   mods:/name[@type="personal"]  ====>   dc.contributor.[author, editor] -->
    <xsl:template match="mods:mods/mods:name/mods:role/mods:roleTerm[.='editor' or .='author']">
        <xsl:variable name="contributorName" select="concat(../../mods:namePart[@type='family'],', ',../../mods:namePart[@type='given'])"/>
        <xsl:element name="dim:field">
            <xsl:attribute name="mdschema">dc</xsl:attribute>
            <xsl:attribute name="element">contributor</xsl:attribute>
            <xsl:attribute name="qualifier">
                <xsl:value-of select="."/>
            </xsl:attribute>
            <xsl:value-of select="$contributorName"/>
        </xsl:element>
        <xsl:if test="../../mods:affiliation">
            <xsl:variable name="contributorAffiliation" select="../../mods:affiliation"/>
            <dim:field mdschema="dcterms" element="contributor" qualifier="affiliation">
                <xsl:value-of select="concat($contributorName, '; ', $contributorAffiliation)"/>
            </dim:field>
        </xsl:if>
    </xsl:template>
    
    <!--   mods:/affiliation  (Affiliation Group) ====>   dcterms.contributor.affiliation   -->
    <xsl:template match="mods:mods/mods:affiliation">
        <dim:field mdschema="dcterms" element="contributor" qualifier="affiliation">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
    
    <!--   mods:/originInfo  ====>   dcterms.bibliographicCitation.originalpublishername, dcterms.bibliographicCitation.originalpublisherplace, dc.date.issued -->
    <xsl:template match="mods:mods/mods:originInfo">
        
        <!--  dcterms.bibliographicCitation.originalpublishername -->
        <xsl:if test="mods:publisher">
            <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="originalpublishername">
                <xsl:value-of select="mods:publisher"/>
            </dim:field>
        </xsl:if>
        
        <!--dcterms.bibliographicCitation.originalpublisherplace -->
        <xsl:if test="mods:place">
            <xsl:for-each select="mods:place/mods:placeTerm">  
                <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="originalpublisherplace">
                    <xsl:value-of select="."/>
                </dim:field>
            </xsl:for-each>
        </xsl:if>
        
        <!--  dc.date.issued, encoding="iso8601"   -->
        <xsl:if test="mods:dateIssued[@encoding='iso8601']">
            <dim:field mdschema="dc" element="date" qualifier="issued">
                <xsl:value-of select="mods:dateIssued"/>
            </dim:field>
        </xsl:if>
    </xsl:template>
    
    
    <!--   mods relatedItem   -->
    <xsl:template match="mods:mods/mods:relatedItem[@type='host']">
         
        <!-- mods:/relatedItem[@type="host"]/titleInfo/title   ====>   dcterms.bibliographicCitation.journaltitle -->
        <xsl:if test="mods:titleInfo/mods:title">
            <xsl:element name="dim:field">
                <xsl:attribute name="mdschema">dcterms</xsl:attribute> 
                <xsl:attribute name="element">bibliographicCitation</xsl:attribute> 
                <xsl:attribute name="qualifier">journaltitle</xsl:attribute>
                <xsl:if test="mods:titleInfo/mods:title/@xml:lang">
                    <xsl:attribute name="lang">
                        <xsl:value-of select="mods:titleInfo/mods:title/@xml:lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space(mods:titleInfo/mods:title)"/>
            </xsl:element> 
        </xsl:if>
        
        <!--   mods:/relatedItem[@type="host"]/identifier[@type="issn' or @type='eIssn' or @type='isbn' 
        ====>   dc.identifier.issn, dc.identifier.eissn, dc.identifier.eissn -->
        <xsl:for-each select="mods:identifier">
            <xsl:if test="@type='issn' or @type='eIssn' or @type='isbn'">
                <xsl:element name="dim:field">
                    <xsl:attribute name="mdschema">dc</xsl:attribute> 
                    <xsl:attribute name="element">identifier</xsl:attribute> 
                    <xsl:attribute name="qualifier">
                        <xsl:value-of select="translate(@type,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
        
        <!--    mods:/relatedItem/part/detail[@type="volume" | @type="issue"]    ====>   dcterms.bibliographicCitation.[volume, issue] -->
        <xsl:if test="mods:part">
            <xsl:for-each select="mods:part/mods:detail">
                <xsl:element name="dim:field">
                    <xsl:attribute name="mdschema">dcterms</xsl:attribute> 
                    <xsl:attribute name="element">bibliographicCitation</xsl:attribute>
                    <xsl:attribute name="qualifier">
                        <xsl:value-of select="@type"/>
                    </xsl:attribute>
                    <xsl:value-of select="mods:number"/>
                </xsl:element>  
            </xsl:for-each>  
            
            <!--  mods:/relatedItem/part/extent[@unit="pages"]    ====>   ddcterms.bibliographicCitation.[pagestart, pageend] -->
            <xsl:if test="mods:part/mods:extent[@unit='pages']">
                <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="pagestart">
                    <xsl:value-of select="mods:part/mods:extent/mods:start"/>
                </dim:field>
                <dim:field mdschema="dcterms" element="bibliographicCitation" qualifier="pageend">
                    <xsl:value-of select="mods:part/mods:extent/mods:end"/>
                </dim:field>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!--  mods:/subject/topic ====>   dc.subject.other  -->
    <xsl:template match="mods:mods/mods:subject">
        <xsl:for-each select="mods:topic">
            <dim:field mdschema="dc" element="subject" qualifier="other">
                <xsl:value-of select="."/>
            </dim:field>
        </xsl:for-each>
    </xsl:template>
    
    
    <!--   mods:/tableOfContents ====>   dc.description.tableofcontents  -->
    <xsl:template match="mods:mods/mods:tableOfContents">
        <dim:field mdschema="dc" element="description" qualifier="tableofcontents">
            <xsl:value-of select="."/>
        </dim:field>
    </xsl:template>
    
    
    <!--   mods:/titleInfo/title ====>   dc.title, dc.title.translated, dc.title.subtitle and dc.title.translatedsubtitle   -->
    <xsl:template match="mods:mods/mods:titleInfo">
        <xsl:for-each select="*">  
            <xsl:element name="dim:field">
                
                <xsl:attribute name="mdschema">dc</xsl:attribute>
                
                <!--  dc.title.subtitle and dc.titletranslatedsubtitle   -->
                <xsl:if test="self::mods:subTitle">
                    <xsl:attribute name="element">title</xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="@type='translated'">
                            <xsl:attribute name="qualifier">translatedsubtitle</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="qualifier">subtitle</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                
                <!-- dc.title and dc.title.translated  -->
                <xsl:if test="self::mods:title">
                    <xsl:attribute name="element">title</xsl:attribute>
                    <!-- Set the qualifier if there is one -->
                    <xsl:if test="@type='translated'"> 
                        <xsl:attribute name="qualifier">
                            <xsl:value-of select="@type"/>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:if>
                
                <!-- Set the language if there is one -->
                <xsl:if test="@xml:lang">
                    <xsl:attribute name="lang">
                        <xsl:value-of select="@xml:lang"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:element> 
        </xsl:for-each>
    </xsl:template>
    
    
</xsl:stylesheet>