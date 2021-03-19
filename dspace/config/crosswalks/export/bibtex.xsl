<?xml version="1.0" encoding="UTF-8" ?>
<!--
    Description: Converts metadata from DSpace DataCite Schema 
                 in the BibTeX file format. If you want to extend this file,
                 please take a look which metadatas are provided by the method
                 org.dspace.util.ExportItemUtils.retrieveMetadata(...).
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:doc="http://www.lyncode.com/xoai"
    version="1.0">
    <xsl:output method="text" />
    
    <!-- Newline as a variable -->
    <xsl:variable name='newline'>
        <xsl:text>&#xa;</xsl:text>
    </xsl:variable>
    <!-- Tab as a variable -->
    <xsl:variable name='tab'>
        <xsl:text>   </xsl:text>
    </xsl:variable>
    
    <xsl:template match="/">
        <!--  <xsl:copy-of select="."/> -->
        <!-- Provider description --> 
        <!-- <xsl:text>Provider: DSpace BibTeX Export</xsl:text> 
        <xsl:value-of select="$newline"></xsl:value-of> -->
        <xsl:text>Repository: </xsl:text>
        <xsl:value-of select="doc:metadata/doc:element[@name='repository']/doc:field[@name='name']/text()"></xsl:value-of>      
        <xsl:value-of select="$newline"></xsl:value-of> 
        <xsl:value-of select="$newline"></xsl:value-of> 
        <xsl:variable name="type" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']/text()"/>

        <!-- @ dc.type -->
        <xsl:choose>
            <xsl:when test="$type = 'Article'">
                <xsl:text>@article</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Doctoral Thesis'">
                <xsl:text>@phdthesis</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Habilitation'">
                <xsl:text>@phdthesis</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Bachelor Thesis'">
                <xsl:text>@mastersthesis</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Master Thesis'">
                <xsl:text>@mastersthesis</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Book'">
                <xsl:text>@book</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Book Part'">
                <xsl:text>@incollection</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Conference Proceedings'">
                <xsl:text>@proceedings</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Conference Object'">
                <xsl:text>@inproceedings</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Report' or $type = 'Research Paper'">
                <xsl:text>@techreport</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Preprint'">
                <xsl:text>@unpublished</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>@misc</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Open citation entry and use handle as key -->
        <xsl:text> { </xsl:text>
        <xsl:value-of select="translate(doc:metadata/doc:element[@name='others']/doc:field[@name='handle']/text(), '/', '_')"></xsl:value-of>
        
        <!-- dc.contributor.author -->
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>author = {</xsl:text>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
                <xsl:if test="position() &gt; 1">
                    <xsl:text> AND </xsl:text>
                </xsl:if>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- If dc.contributor.author does not exist, dc.contributor.organisation is mapped as author-->
        <xsl:if test="($type = 'Report' or $type = 'Research Paper' or $type = 'Book' or $type = 'Conference Proceedings' or $type = 'Periodical Part') 
                      and (doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation'])
                      and not(doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author'] 
                              or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor'])"> 
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>author = {</xsl:text>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation']/doc:element/doc:field[@name='value']">
                <xsl:if test="position() &gt; 1">
                    <xsl:text> AND </xsl:text>
                </xsl:if>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:text>}</xsl:text>  
        </xsl:if>
        
        <!-- dc.contributor.editor -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']" > 
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>editor = {</xsl:text>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
                <xsl:if test="position() &gt; 1">
                    <xsl:text> AND </xsl:text>
                </xsl:if>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.title (and, if exists subtitle)-->
        <xsl:text>,</xsl:text>
        <xsl:value-of select="$newline"></xsl:value-of>    
        <xsl:value-of select="$tab"></xsl:value-of>
        <xsl:text>title = {</xsl:text>
        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']">
            <xsl:text> : </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']/text()"/>
        </xsl:if>
        <xsl:text>}</xsl:text>
        
        <!-- dcterms.bibliographicCitation.booktitle -->
        <xsl:if test="($type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='booktitle']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>booktitle = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='booktitle']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!--dcterms.bibliographicCitation.journaltitle -->
        <xsl:if test="$type = 'Article' and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='journaltitle']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>journal = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='journaltitle']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.contributor.grantor -->
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis'">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>school = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='grantor']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.contributor.organisation or tub.publisher.universityorinstitution -->
        <xsl:if test="not($type = 'Article' or $type = 'Book' or $type = 'Book Part' or $type = 'Doctoral Thesis' 
                          or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis' or $type = 'Conference Proceedings'
                          or $type = 'Conference Object' or $type = 'Preprint') and
                          (doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution'] 
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation'])">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>institution = {</xsl:text>
            <xsl:choose>
                <xsl:when test="$type = 'Report' or $type = 'Research Paper'">
                    <xsl:choose>
                        <xsl:when test="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']">
                            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.date.issued --> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>year = {</xsl:text>
            <xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value'], 1, 4)"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.publisher.name or dcterms.bibliographicCitation.originalpublishername --> 
        <xsl:if test="(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='name']/doc:element/doc:field[@name='value'][contains(text(), 'Universitätsverlag der TU Berlin')] and ($type = 'Book' or $type = 'Conference Proceedings' or $type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis'))
                      or (doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='originalpublishername'] and ($type = 'Book Part' or $type = 'Conference Object'))">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>publisher = {</xsl:text>
            <xsl:choose>
                <!-- dcterms.bibliographicCitation.originalpublishername -->
                <xsl:when test="$type = 'Book Part' or $type = 'Conference Object'">            
                    <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.type --> 
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis'" >
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>type = {</xsl:text>
            <xsl:value-of select="$type"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.volume -->
        <xsl:if test="$type = 'Article' and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>volume = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.issue -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='issue']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>number = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='issue']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.pagestart concatenated with 2x endash ("–") dcterms.bibliographicCitation.pageend -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') 
                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart']
                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>pages = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>--</xsl:text>            
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>            
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.articlenumber -->
        <xsl:if test="(($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') 
                                        and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='articlenumber']) 
                                        and not(doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart'] 
                                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend'])">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>pages = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>            
        </xsl:if>
        
        <!-- Book Part or Conference Object editor: dcterms.bibliographicCitation.editor -->
        <xsl:if test="($type = 'Book Part' or $type = 'Conference Object')
                      and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='editor']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>editor = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='editor']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>            
        </xsl:if>
        
        <!-- tub.series.issuenumber -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']" >
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>volume = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- tub.series.name -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']" >
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>series = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.publisher.place --> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='place']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>address = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='place']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- address hard coded -->
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis'" >
            <xsl:text>,</xsl:text> 
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>address = {Berlin}</xsl:text>
        </xsl:if>
        
        <!-- dc.description.edition--> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>edition = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
          
        <!-- "Available Open Access" + dc.type.version + "at" + dc.identifier.uri -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>note = {</xsl:text>
            <xsl:text>Available Open Access </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> at </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- Periodical Part note: tub.series.name + " ; " + tub.series.issuenumber -->
        <xsl:if test="not($type = 'Article' or $type = 'Book' or $type = 'Book Part' or $type = 'Doctoral Thesis' 
                          or $type = 'Habilitation' or $type = 'Bachelor Thesis' or $type = 'Master Thesis' or $type = 'Conference Proceedings'
                          or $type = 'Conference Object' or $type = 'Report' or $type = 'Research Paper' or $type = 'Preprint')
                      and (doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']
                      and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber'])"> 
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>note = {</xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>         
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- Preprint note: dc.type + tub.publisher.universityorinstitution -->
        <xsl:if test="$type = 'Preprint'
                      and doc:metadata/doc:element[@name='dc']/doc:element[@name='type']
                      and doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']"> 
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>note = {</xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>         
            <xsl:text>}</xsl:text>
        </xsl:if>
                     
        <!-- dc.identifier.uri : doi substring http://dx.doi.org/ or dcterms.bibliographicCitation.doi for article and book part -->       
        <xsl:if test="(($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi'])
                       or (not ($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')])">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>doi = {</xsl:text>
            <xsl:choose>
                <!-- dcterms.bibliographicCitation.doi -->
                <xsl:when test="$type = 'Article' or $type = 'Book Part' or $type = 'Conference Object'">
                    <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')], 19)"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
            <!-- url  we can not expected that the user included \usepackage{url}-->
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>url = {</xsl:text>
            <xsl:choose>
                <!-- dcterms.bibliographicCitation.doi -->
                <xsl:when test="$type = 'Article' or $type = 'Book Part' or $type = 'Conference Object'">
                    <xsl:text>https://doi.org/</xsl:text>
                    <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')]"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.subject.other -->
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:value-of select="$tab"></xsl:value-of>      	
            <xsl:text>keywords = {</xsl:text>
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']/doc:element/doc:field[@name='value']">
                <xsl:if test="position() &gt; 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:value-of select="."></xsl:value-of>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- dc.description.abstract -->
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']">
            <xsl:text>,</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>    
            <xsl:value-of select="$tab"></xsl:value-of>
            <xsl:text>abstract = {</xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text>}</xsl:text>
        </xsl:if>
        
        <!-- Closecitation entry-->
        <xsl:value-of select="$newline"></xsl:value-of>
        <xsl:text>}</xsl:text>
    </xsl:template>
</xsl:stylesheet>