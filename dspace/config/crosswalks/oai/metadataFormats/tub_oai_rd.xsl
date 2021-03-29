<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd

-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai"
    version="1.0">
    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
    <xsl:template match="/">
        <oai_datacite 
            xsi:schemaLocation="http://schema.datacite.org/oai/oai-1.1 http://schema.datacite.org/oai/oai-1.1/oai.xsd" 
            xmlns="http://datacite.org/schema/kernel-3" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            
            <!-- dc.title and dc.title.* -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']">
                <titles>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
                        <title>
                            <xsl:value-of select="." />
                        </title>
                    </xsl:for-each>
                    <!-- dc.title.translated -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field[@name='value']">	
                        <title titleType="TranslatedTitle">
                            <xsl:value-of select="." />
                        </title>
                    </xsl:for-each>
                    <!-- dc.title.alternative -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">	
                        <title titleType="Alternative Title">
                            <xsl:value-of select="." />
                        </title>
                    </xsl:for-each>
                    <!-- dc.title.subtitle -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']">	
                        <title titleType="Subtitle">
                            <xsl:value-of select="." />
                        </title>
                    </xsl:for-each>
                </titles>
            </xsl:if>
            
            <!-- dc.contributor.author --> 
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
                <creators>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
                        <creator>
                            <creatorName>
                                <xsl:value-of select="." />
                            </creatorName>
                        </creator>
                    </xsl:for-each>
                </creators>
            </xsl:if>
            
            <!-- There are many dc.contributor.* values which should properly matche the Controlled List Values of OAI.
            Currently only the dc.contributor.other is include.  The dc.description.sponsorship is also part of the contributors --> 
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='other']/doc:element/doc:field[@name='value']
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field[@name='value'][text() != '' and starts-with(text(), 'info')]"> 
                <contributors>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='other']/doc:element/doc:field[@name='value']">   
                        <contributor contributorType="Other">
                            <contributorName>
                                <xsl:value-of select="." />
                            </contributorName>
                        </contributor>
                    </xsl:for-each>
                    <!-- dc.description.sponsorship -->
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='sponsorship']/doc:element/doc:field[@name='value'][text() != '' and starts-with(text(), 'info')]">
                        <contributor contributorType="Funder">
                            <contributorName>European Commission</contributorName>
                            <nameIdentifier nameIdentifierScheme="info">
                                <xsl:value-of select="." />
                            </nameIdentifier>
                        </contributor>
                    </xsl:for-each>
                </contributors>
            </xsl:if>
            
            <!-- dc.publisher -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
                <publisher>
                    <xsl:value-of select="." />
                </publisher>
            </xsl:for-each>
            <!-- tub.publisher.universityorinstitution -->
            <xsl:for-each select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']">
                <publisher>
                    <xsl:value-of select="." />
                </publisher>
            </xsl:for-each>
                   
            <!-- dc.identifier.uri : DOI.
            DOI is the only identifier. Others identifiers are alternateIdentifiers -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')]">
                <identifier identifierType="DOI">
                    <xsl:value-of select="." />
                </identifier>
            </xsl:for-each>
            
            <!-- AlternateIdentifiers -->
            <!-- dc.identifier.uri : Handle, dc.identifier.isbn -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
                <alternateIdentifiers>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                        <alternateIdentifier alternateIdentifierType="Handle">
                            <xsl:value-of select="." />
                        </alternateIdentifier>
                    </xsl:for-each>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">   
                        <alternateIdentifier alternateIdentifierType="ISBN">
                            <xsl:value-of select="." />
                        </alternateIdentifier>
                    </xsl:for-each>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">   
                        <alternateIdentifier alternateIdentifierType="ISSN">
                            <xsl:value-of select="." />
                        </alternateIdentifier>
                    </xsl:for-each>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']">   
                        <alternateIdentifier alternateIdentifierType="EISSN">
                            <xsl:value-of select="." />
                        </alternateIdentifier>
                    </xsl:for-each>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">   
                        <alternateIdentifier alternateIdentifierType="URN">
                            <xsl:value-of select="." />
                        </alternateIdentifier>
                    </xsl:for-each>
                </alternateIdentifiers>
            </xsl:if>
                        
            <!-- publicationYear year of dc.date.issued -->  
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
                <publicationYear>
                    <xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value'], 1, 4)" />
                </publicationYear>
            </xsl:if>
                
            <!-- dc.language -->
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
                <language>
                    <xsl:value-of select="." />
                </language>
            </xsl:for-each>
                
            <!-- dc.date -->
            <dates>
                <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
                        <date dateType="Issued">
                            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']" />
                        </date>
                </xsl:if>
                <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']">
                        <date dateType="Available">
                            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']/doc:element/doc:field[@name='value']" />
                        </date>
                </xsl:if>
            </dates>

            <!-- dc.subject -->
            <!-- dc.subject.* like (classification, ddc, lcc, lcsh, mesh) are not included -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']">
                <subjects>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']/doc:element/doc:field[@name='value']">
                        <subject>
                            <xsl:value-of select="." />
                        </subject>
                    </xsl:for-each>
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='ddc']/doc:element/doc:field[@name='value']">
                        <subject subjectScheme="DDC" schemeURI="http://dewey.info/">
                            <xsl:value-of select="." />
                        </subject>
                    </xsl:for-each>
                </subjects>
            </xsl:if>
                      
            <!-- dc.type --> 
            <!-- Type: Generic Research Data, Textual Data, Audio, Video, Image, Software, 3D Model, ... -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']">
                <xsl:for-each  select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="resourceTypeGeneral" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($resourceTypeGeneral, 'Animation') or contains($resourceTypeGeneral, 'Video')">
                            <resourceType resourceTypeGeneral="Audiovisual">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when> 
                        <xsl:when test="contains($resourceTypeGeneral, 'Dataset') or contains($resourceTypeGeneral, 'Generic Research Data')">
                            <resourceType resourceTypeGeneral="Dataset">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when> 
                        <xsl:when test="contains($resourceTypeGeneral, 'Image') or contains($resourceTypeGeneral, 'Image, 3-D')">
                            <resourceType resourceTypeGeneral="Image">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when>
                        <xsl:when test="contains($resourceTypeGeneral, 'Learning Object')">
                            <resourceType resourceTypeGeneral="InteractiveResource">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when>
                        <xsl:when test="contains($resourceTypeGeneral, 'Map') or contains($resourceTypeGeneral, 'Plan or blueprint')">
                            <resourceType resourceTypeGeneral="Model">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when>
                        <xsl:when test="contains($resourceTypeGeneral, 'Software')">
                            <resourceType resourceTypeGeneral="Software">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when>
                        <xsl:when test="contains($resourceTypeGeneral, 'Audio') or contains($resourceTypeGeneral, 'Recording, acoustical') or contains($resourceTypeGeneral, 'Recording, musical') or contains($resourceTypeGeneral, 'Recording, oral')">
                            <resourceType resourceTypeGeneral="Sound">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:when>
                        <xsl:otherwise>
                            <resourceType resourceTypeGeneral="Other">
                                <xsl:value-of select="$resourceTypeGeneral" />
                            </resourceType>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if> 
                        
            <!-- dc.relation.* : haspart, ispartof, isreferencedby, issupplementedby, issupplementto, references -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='haspart']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='haspart']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='haspart']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="HasPart">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="HasPart">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="IsPartOf">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="IsPartOf">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isreferencedby']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isreferencedby']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isreferencedby']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="IsReferencedBy">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="IsReferencedBy">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementedby']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementedby']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementedby']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="IsSupplementedBy">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="IsSupplementedBy">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementto']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementto']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issupplementto']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="IsSupplementTo">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="IsSupplementTo">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='references']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')] 
                                    or doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='references']/doc:element/doc:field[@name='value'][contains(text(), '/handle/')]">
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='references']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="relatedIdentifierType" select="."/>
                    <xsl:choose>
                        <xsl:when test="contains($relatedIdentifierType, 'doi.org')">
                            <relatedIdentifier relatedIdentifierType="DOI" relationType="References">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:when>
                        <xsl:otherwise>
                            <relatedIdentifier relatedIdentifierType="Handle" relationType="References">
                                <xsl:value-of select="$relatedIdentifierType" />
                            </relatedIdentifier>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
			
            <!-- Rights -->
            <rightsList>
                <!-- rights for openAire from embargo_selector.xsl -->
                <xsl:for-each select="doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess']">
                    <xsl:variable name="rightsURI" select="."/>
                    <rights rightsURI="{$rightsURI}"/>
                </xsl:for-each>
                <!-- dc.rights.uri -->
                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
                    <xsl:variable name="rightsURI" select="."/>
                    <rights rightsURI="{$rightsURI}" />
                </xsl:for-each>
            </rightsList>

            <!-- dc.description --> 
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']">
                <descriptions>    
                    <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">	
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">	
                            <description descriptionType="Abstract">
                                <xsl:value-of select="." />
                            </description>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='tableofcontents']/doc:element/doc:field[@name='value']">	
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='tableofcontents']/doc:element/doc:field[@name='value']">	
                            <description descriptionType="TableOfContents">
                                <xsl:value-of select="." />
                            </description>
                        </xsl:for-each>
                    </xsl:if> 
                    <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='tableofcontents' and @name!='abstract' and @name!='sponsorship']/doc:element/doc:field[@name='value']">	
                        <description descriptionType="Other">
                            <xsl:value-of select="." />
                        </description>
                    </xsl:for-each>
                </descriptions>
            </xsl:if>
            
            <!-- Adds the distinct format of bitstreams and their total sizes -->
            <xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
                <formats>
                    <xsl:for-each select="../doc:element[@name='bitstreams']/doc:element">
                        <xsl:if test="doc:field[@name='format']/text()[not(.=preceding::*)]">
                            <format> 
                                <xsl:value-of select="doc:field[@name='format']/text()" /> 
                            </format>
                        </xsl:if>
                    </xsl:for-each>
                </formats>
                <sizes>
                    <size>
                        <xsl:value-of select="./doc:field/text()" /> 
                    </size>
                </sizes> 
            </xsl:for-each>
            
            <!-- For openAire: embargoEnd (set in embargo_selector.xsl) -->
            <xsl:if test="contains(doc:metadata/doc:element[@name='others']/doc:field[@name='openAireAccess'], 'embargoedAccess')">
                <xsl:for-each select="doc:metadata/doc:element[@name='others']/doc:field[@name='embargoEnd']">
                    <date>
                        <xsl:value-of select="concat('info:eu-repo/date/embargoEnd/', .)" />
                    </date>
                </xsl:for-each>
            </xsl:if>
            
        </oai_datacite>
    </xsl:template>
</xsl:stylesheet>
