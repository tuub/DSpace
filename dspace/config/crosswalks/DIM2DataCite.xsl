<?xml version="1.0" encoding="UTF-8"?>

<!--
    Document   : DIM2DataCite.xsl
    Created on : January 23, 2013, 1:26 PM
    Author     : pbecker, ffuerste
    Description: Converts metadata from DSpace Intermediat Format (DIM) into
                 metadata following the DataCite Schema for the Publication and
                 Citation of Research Data, Version 2.2
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dspace="http://www.dspace.org/xmlns/dspace/dim"
                xmlns="http://datacite.org/schema/kernel-2.2"
                version="1.0">
    
    <!-- CONFIGURATION -->
    <!-- The content of the following variable will be used as element publisher. -->
    <xsl:variable name="publisher">My University</xsl:variable>
    <!-- The content of the following variable will be used as element contributor with contributorType datamanager. -->
    <xsl:variable name="datamanager"><xsl:value-of select="$publisher" /></xsl:variable>
    <!-- The content of the following variable will be used as element contributor with contributorType hostingInstitution. -->
    <xsl:variable name="hostinginstitution"><xsl:value-of select="$publisher" /></xsl:variable>
    <!-- Please take a look into the DataCite schema documentation if you want to know how to use these elements.
         http://schema.datacite.org -->
    
    
    <!-- DO NOT CHANGE ANYTHING BELOW THIS LINE EXCEPT YOU REALLY KNOW WHAT YOU ARE DOING! -->
    
    <xsl:output method="xml" indent="yes" encoding="utf-8" />
    
    <!-- Don't copy everything by default! -->
    <xsl:template match="@* | text()" />
    
    <xsl:template match="/dspace:dim[@dspaceType='ITEM']">
        <!--
            org.dspace.identifier.doi.DataCiteConnector uses this XSLT to
            transform metadata for the DataCite metadata store. This crosswalk
            should only be used, when it is ensured that all mandatory
            properties are in the metadata of the item to export.
            The classe named above respects this.
        -->
        <resource xmlns="http://datacite.org/schema/kernel-2.2"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xsi:schemaLocation="http://datacite.org/schema/kernel-2.2 http://schema.datacite.org/meta/kernel-2.2/metadata.xsd">

            <!-- 
                MANDATORY PROPERTIES
            -->

            <!-- 
                DataCite (1)
                Template Call for DOI identifier.
            --> 
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='identifier' and starts-with(., 'doi')]" />

            <!-- 
                DataCite (2)
                Add creator information. 
            -->
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
                <creators>
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='contributor' and @qualifier='author']" />
                </creators>
            </xsl:if>

            <!-- 
                DataCite (3)
                Add Title information. 
            -->
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='title']">
                <titles>
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='title']" />
                </titles>
            </xsl:if>
            
            <!-- 
                DataCite (4)
                Add Publisher information from configuration above
            -->
            <publisher>
                <xsl:value-of select="$publisher" />
            </publisher>

            <!-- 
                DataCite (5)
                Add PublicationYear information
            -->
            <publicationYear>
                <xsl:choose>
                    <xsl:when test="//dspace:field[@mdschema='dc' and @element='date' and @qualifier='issued']">
                        <xsl:value-of select="substring(//dspace:field[@mdschema='dc' and @element='date' and @qualifier='issued'], 1, 4)" />
                    </xsl:when>
                    <xsl:when test="//dspace:field[@mdschema='dc' and @element='date' and @qualifier='available']">
                        <xsl:value-of select="substring(//dspace:field[@mdschema='dc' and @element='date' and @qualifier='issued'], 1, 4)" />
                    </xsl:when>
                    <xsl:when test="//dspace:field[@mdschema='dc' and @element='date']">
                        <xsl:value-of select="substring(//dspace:field[@mdschema='dc' and @element='date'], 1, 4)" />
                    </xsl:when>
                    <xsl:otherwise>0000</xsl:otherwise>
                </xsl:choose>
            </publicationYear>

            <!-- 
                OPTIONAL PROPERTIES
            -->

            <!-- 
                DataCite (6)
                Template Call for subjects.
            -->  
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='subject']">
                <subjects>
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='subject']" />
                </subjects>
            </xsl:if>

            <!-- 
                DataCite (7)
                Add contributorType from configuration above.
                Template Call for Contributors
            --> 
            <contributors>
                <xsl:element name="contributor">
                    <xsl:attribute name="contributorType">DataManager</xsl:attribute>
                    <xsl:element name="contributorName">
                        <xsl:value-of select="$datamanager"/>
                    </xsl:element>    
                </xsl:element>
                <xsl:element name="contributor">
                    <xsl:attribute name="contributorType">HostingInstitution</xsl:attribute>
                    <contributorName>
                        <xsl:value-of select="$hostinginstitution" />
                    </contributorName>
                </xsl:element>
                <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='contributor'][not(@qualifier='author')]" />
            </contributors>

            <!-- 
                DataCite (8)
                Template Call for Dates
            --> 
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='date']" >
                <dates>
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='date']" />
                </dates>
            </xsl:if>

            <!-- Add language(s). -->
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='language' and @qualifier='iso']" />

            <!-- Add resource type. -->
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='type']" />

            <!-- 
                 Add alternativeIdentifiers.
                 This element is important as it is used to recognize for which
                 DSpace object a DOI is reserved for. See below for further 
                 information.
            -->
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='identifier' and not(starts-with(., 'doi:'))]">
                <xsl:element name="alternateIdentifiers">
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='identifier' and not(starts-with(., 'doi:'))]" />
                </xsl:element>
            </xsl:if>

            <!-- Add sizes. -->
            <!--
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='format' and @qualifier='extent']">             
                <sizes>
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='format' and @qualifier='extent']" />      
                </sizes>
            </xsl:if>
            -->

            <!-- Add formats. -->
            <!--
            <xsl:if test="//dspace:field[@mdschema='dc' and @element='format']">     
                <formats>                
                    <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='format']" />       
                </formats>
            </xsl:if>
            -->

            <!-- Add version. --> 
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='description' and @qualifier='provenance']" />

            <!-- Add rights. -->
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='rights']" />

            <!-- Add descriptions. -->
            <xsl:apply-templates select="//dspace:field[@mdschema='dc' and @element='description'][not(@qualifier='provenance')]" />

        </resource>
    </xsl:template>
    

    <!-- Add doi identifier information. -->
    <xsl:template match="dspace:field[@mdschema='dc' and @element='identifier' and starts-with(., 'doi')]">
        <Identifier identifierType="DOI">
            <xsl:value-of select="substring(., 5)"/>
        </Identifier>
    </xsl:template>
    
    <!-- DataCite (2) :: Creator -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='contributor' and @qualifier='author']">
        <creator>
            <creatorName>
                <xsl:value-of select="." />
            </creatorName>
        </creator>
    </xsl:template>

    <!-- DataCite (3) :: Title -->
    <xsl:template match="dspace:field[@mdschema='dc' and @element='title']">
        <xsl:element name="title">
            <xsl:if test="@qualifier='alternative'">
                <xsl:attribute name="titleType">AlternativeTitle</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (6), DataCite (6.1)
        Adds subject and subjectScheme information
    
        "This term is intended to be used with non-literal values as defined in the 
        DCMI Abstract Model (http://dublincore.org/documents/abstract-model/). 
        As of December 2007, the DCMI Usage Board is seeking a way to express 
        this intention with a formal range declaration." 
        (http://dublincore.org/documents/dcmi-terms/#terms-subject)
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='subject']">
        <xsl:element name="subject">
            <xsl:if test="@qualifier">
                <xsl:attribute name="subjectScheme"><xsl:value-of select="@qualifier" /></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (7), DataCite (7.1) 
        Adds contributor and contributorType information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='contributor'][not(@qualifier='author')]">
        <xsl:element name="contributor">
            <xsl:if test="@qualifier='editor'">
                <xsl:attribute name="contributorType">Editor</xsl:attribute>
            </xsl:if>
            <contributorName>
                <xsl:value-of select="." />
            </contributorName>
        </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (8), DataCite (8.1)
        Adds Date and dateType information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='date']">
            <xsl:element name="date">
                <xsl:if test="@qualifier='accessioned'">
                    <xsl:attribute name="dateType">Issued</xsl:attribute>
                </xsl:if>
                <xsl:if test="@qualifier='submitted'">
                    <xsl:attribute name="dateType">Issued</xsl:attribute>
                </xsl:if>
                <!-- part of DublinCore DSpace to mapping but not part of DSpace default fields
                <xsl:if test="@qualifier='dateAccepted'">
                    <xsl:attribute name="dateType">Issued</xsl:attribute>
                </xsl:if>
                -->
                <xsl:if test="@qualifier='issued'">
                    <xsl:attribute name="dateType">Issued</xsl:attribute>
                </xsl:if>
                <xsl:if test="@qualifier='available'">
                    <xsl:attribute name="dateType">Available</xsl:attribute>
                </xsl:if>
                <xsl:if test="@qualifier='copyright'">
                    <xsl:attribute name="dateType">Copyrighted</xsl:attribute>
                </xsl:if>
                <xsl:if test="@qualifier='created'">
                    <xsl:attribute name="dateType">Created</xsl:attribute>
                </xsl:if>
                <xsl:if test="@qualifier='updated'">
                    <xsl:attribute name="dateType">Updated</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="substring(., 1, 10)" />
            </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (9)
        Adds Language information
        Transforming the language flags according to ISO 639-2/B & ISO 639-3
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='language' and @qualifier='iso']">
        <xsl:for-each select=".">
            <xsl:element name="language">
                <xsl:choose>
                    <xsl:when test="string(text())='en'">eng</xsl:when>
                    <xsl:when test="string(text())='de'">ger</xsl:when>
                    <xsl:when test="string(text())='fr'">fre</xsl:when>
                    <xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- 
        DataCite (10), DataCite (10.1)
        Adds resourceType and resourceTypeGeneral information
    -->
        <xsl:template match="//dspace:field[@mdschema='dc' and @element='type']">
        <xsl:for-each select=".">
            <!-- Transforming the language flags according to ISO 639-2/B & ISO 639-3 -->
            <xsl:element name="ResourceType">
                <xsl:attribute name="resourceTypeGeneral">
                    <xsl:choose>
                        <xsl:when test="string(text())='Animation'">Image</xsl:when>
                        <xsl:when test="string(text())='Article'">Text</xsl:when>
                        <xsl:when test="string(text())='Book'">Text</xsl:when>
                        <xsl:when test="string(text())='Book chapter'">Text</xsl:when>
                        <xsl:when test="string(text())='Dataset'">Dataset</xsl:when>
                        <xsl:when test="string(text())='Learning Object'">InteractiveResource</xsl:when>
                        <xsl:when test="string(text())='Image'">Image</xsl:when>
                        <xsl:when test="string(text())='Image, 3-D'">Image</xsl:when>
                        <xsl:when test="string(text())='Map'">Image</xsl:when>
                        <xsl:when test="string(text())='Musical Score'">Sound</xsl:when>
                        <xsl:when test="string(text())='Plan or blueprint'">Image</xsl:when>
                        <xsl:when test="string(text())='Preprint'">Text</xsl:when>
                        <xsl:when test="string(text())='Presentation'">Image</xsl:when>
                        <xsl:when test="string(text())='Recording, acoustical'">Sound</xsl:when>
                        <xsl:when test="string(text())='Recording, musical'">Sound</xsl:when>
                        <xsl:when test="string(text())='Recording, oral'">Sound</xsl:when>
                        <xsl:when test="string(text())='Software'">Software</xsl:when>
                        <xsl:when test="string(text())='Technical Report'">Text</xsl:when>
                        <xsl:when test="string(text())='Thesis'">Text</xsl:when>
                        <xsl:when test="string(text())='Video'">Film</xsl:when>
                        <xsl:when test="string(text())='Working Paper'">Text</xsl:when>
                        <!-- FIXME -->
                        <xsl:when test="string(text())='Other'">Collection</xsl:when>
                        <!-- FIXME -->
                        <xsl:otherwise>Collection</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!--
        DataCite (11), DataCite (11.1) 
        Adds AlternativeIdentifier and alternativeIdentifierType information
        Adds all identifiers except the doi.

        This element is important as it is used to recognize for which DSpace
        objet a DOI is reserved for. The DataCiteConnector will test all
        AlternativeIdentifiers by using HandleManager.
        resolveUrlToHandle(context, altId) until one is recognized or all have
        been tested.
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='identifier' and not(starts-with(., 'doi:'))]">
        <xsl:element name="alternateIdentifier">
            <xsl:if test="@qualifier">
                <xsl:attribute name="alternateIdentifierType"><xsl:value-of select="@qualifier" /></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!--
        DataCite (12), DataCite (12.1) 
        Adds RelatedIdentifier and relatedIdentifierType information
    -->

    <!-- 
        DataCite (13)
        Adds Size information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='format' and @qualifier='extent']">
        <xsl:element name="format">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (14)
        Adds Format information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='format']">
        <xsl:element name="format">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>

    <!-- 
        DataCite (15)
        Adds Version information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='description' and @qualifier='provenance']">
        <xsl:if test="contains(text(),'Made available')">
            <xsl:element name="version">
                <xsl:value-of select="." />
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- 
        DataCite (16)
        Adds Rights information
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='rights']">
        <xsl:element name="rights">
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
    <!-- 
        DataCite (17)
        Description
    -->
    <xsl:template match="//dspace:field[@mdschema='dc' and @element='description'][not(@qualifier='provenance')]">
        <xsl:element name="description">
            <xsl:attribute name="descriptionType">
           	<xsl:choose>           
                    <xsl:when test="@qualifier='abstract'">Abstract</xsl:when>
               	    <xsl:otherwise>Other</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="." />
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
