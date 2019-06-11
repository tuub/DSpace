<?xml version="1.0" encoding="UTF-8" ?>
<!--
    Description: Converts metadata from DSpace DataCite Schema 
                 in the RIS file format. If you want to extend this file,
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
    
    <xsl:template match="/">
        
        <!-- Provider description --> 
        <!--   <xsl:text>Provider: DSpace RIS Export</xsl:text>
        <xsl:value-of select="$newline"></xsl:value-of> -->
        <xsl:text>Repository: </xsl:text>
        <xsl:value-of select="doc:metadata/doc:element[@name='repository']/doc:field[@name='name']/text()"></xsl:value-of>      
        <xsl:value-of select="$newline"></xsl:value-of> 
        <xsl:value-of select="$newline"></xsl:value-of>         
        <xsl:variable name="type" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']/text()"/>
        
        <!-- @ dc.type -->
        <xsl:text>TY  - </xsl:text>
        <xsl:choose>
            <xsl:when test="$type = 'Article'">
                <xsl:text>EJOUR</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Master Thesis'">
                <xsl:text>THES</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Book'">
                <xsl:text>BOOK</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Book Part'">
                <xsl:text>CHAP</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Conference Proceedings'">
                <xsl:text>CONF</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Conference Object'">
                <xsl:text>CPAPER</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Report' or $type = 'Research Paper'">
                <xsl:text>RPRT</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Preprint'">
                <xsl:text>Unpublished work</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Image'">
                <xsl:text>FIGURE</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Video'">
                <xsl:text>VIDEO</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Audio' ">
                <xsl:text>SOUND</xsl:text>
            </xsl:when>
            <xsl:when test="$type ='Multimedia'">
                <xsl:text>MULTI</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Software'">
                <xsl:text>Computer program</xsl:text>
            </xsl:when>
            <xsl:when test="$type = 'Textual Data'">
                <xsl:text>DATA</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>GEN</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"></xsl:value-of>
         
        <!-- dc.contributor.author -->      		
        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
            <xsl:text>AU  - </xsl:text>
            <xsl:value-of select="."></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:for-each>	
        
        <!-- If dc.contributor.author does not exist, dc.contributor.organisation is mapped as author-->
         <xsl:if test="($type = 'Report' or $type = 'Research Paper' or $type = 'Book' or $type = 'Conference Proceedings' or $type = 'Periodical Part') 
                      and (doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation'])
                      and not(doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author'] 
                              or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor'])"> 
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation']/doc:element/doc:field[@name='value']">
                <xsl:text>AU  - </xsl:text>
                <xsl:value-of select="."></xsl:value-of>
                <xsl:value-of select="$newline"></xsl:value-of>
            </xsl:for-each>
        </xsl:if>
        
        <!-- dc.contributor.editor -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']" > 
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
                <xsl:text>A2  - </xsl:text>
                <xsl:value-of select="."></xsl:value-of>
                <xsl:value-of select="$newline"></xsl:value-of>
            </xsl:for-each>
        </xsl:if>
                        	
        <!-- dc.date.issued --> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']">
            <xsl:text>PY  - </xsl:text>
            <xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value'], 1, 4)"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.title -->      		
        <xsl:text>TI  - </xsl:text>
        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
        <xsl:value-of select="$newline"></xsl:value-of>
        
        <!-- dc.title.subtitle -->
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']">
            <xsl:text>ST  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']/text()"/>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.booktitle -->
        <xsl:if test="($type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='booktitle']">
            <xsl:text>T2  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='booktitle']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
     
        <!--dcterms.bibliographicCitation.journaltitle -->
        <xsl:if test="$type = 'Article' and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='journaltitle']">
            <xsl:text>T2  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='journaltitle']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.contributor.grantor -->
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or $type = 'Master Thesis'">
            <xsl:text>T2  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='grantor']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        	
        <!-- dc.identifier.uri : doi substring http://dx.doi.org/ or dcterms.bibliographicCitation.doi for article and book part -->       
        <xsl:if test="(($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi'])
                       or (not ($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')])">
            <xsl:text>DO  - </xsl:text>
            <xsl:choose>
                <!-- dcterms.bibliographicCitation.doi -->
                <xsl:when test="$type = 'Article' or $type = 'Book Part' or $type = 'Conference Object'">
                    <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="substring(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')], 19)"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$newline"></xsl:value-of>
            <!-- url  we can not expected that the user included \usepackage{url}-->
            <xsl:text>UR  - </xsl:text>
            <xsl:choose>
                <!-- dcterms.bibliographicCitation.doi -->
                <xsl:when test="$type = 'Article' or $type = 'Book Part'  or $type = 'Conference Object'">
                    <xsl:text>https://doi.org/</xsl:text>
                    <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='doi']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                </xsl:when> 
                <xsl:otherwise>
                    <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'][contains(text(), 'doi.org')]"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- publisher --> 
        <xsl:if test="not($type = 'Article' or $type = 'Conference Object' or $type = 'Preprint') and
                          (doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution'] 
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation'] 
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']
                          or doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='originalpublishername'] 
                          or doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution'])">
            <xsl:text>PB  - </xsl:text>
            <xsl:choose>
                <!-- dc.contributor.organisation -->
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
                <xsl:when test="(doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='name']/doc:element/doc:field[@name='value'][contains(text(), 'Universitätsverlag der TU Berlin')] and ($type = 'Book' or $type = 'Conference Proceedings' or $type = 'Doctoral Thesis' or $type = 'Habilitation' or  $type = 'Master Thesis'))
                      or (doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='originalpublishername'] and ($type = 'Book Part' or $type = 'Conference Object'))">
                    <xsl:choose>
                        <!-- dcterms.bibliographicCitation.originalpublishername -->
                        <xsl:when test="$type = 'Book Part' or $type = 'Conference Object'">            
                            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                        </xsl:when> 
                        <xsl:otherwise>
                            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- tub.publisher.universityorinstitution -->
                    <xsl:if test="not($type = 'Article'or $type = 'Conference Object' or $type = 'Preprint') and
                          (doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution'] 
                          or doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation'])">
                        <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.type --> 
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or  $type = 'Master Thesis'" >
            <xsl:text>M3  - </xsl:text>
            <xsl:value-of select="$type"></xsl:value-of> 
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.volume -->
        <xsl:if test="$type = 'Article' and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']">
            <xsl:text>VL  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.issue -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part') and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='issue']">
            <xsl:text>IS  - </xsl:text>  
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='issue']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.pagestart concatenated with 2x endash ("–") dcterms.bibliographicCitation.pageend -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') 
                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart']
                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend']">
            <xsl:text>SP  - </xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
            <xsl:text>EP  - </xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dcterms.bibliographicCitation.articlenumber -->
        <xsl:if test="(($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') 
                                        and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='articlenumber']) 
                                        and not(doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pagestart'] 
                                                and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='pageend'])">
            <xsl:text>SP  - </xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
       
        <!-- Book Part or Conference Object editor: dcterms.bibliographicCitation.editor  -->
        <xsl:if test="($type = 'Book Part' or $type = 'Conference Object')
                      and doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='editor']">
            <xsl:text>A2  - </xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='editor']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>            
        </xsl:if> 
        
        <!-- tub.series.issuenumber ??? number -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']" >
            <xsl:text>NV  - </xsl:text> 
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>            
        </xsl:if>
        
        <!-- tub.series.name -->
        <xsl:if test="($type = 'Book' or $type = 'Conference Proceedings') and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']" >
            <xsl:text>T2  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.publisher.place --> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='place']">
            <xsl:text>CY  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element[@name='place']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- address hard coded -->
        <xsl:if test="$type = 'Doctoral Thesis' or $type = 'Habilitation' or  $type = 'Master Thesis'" >
            <xsl:text>CY  - Berlin</xsl:text>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.description.edition--> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']">
            <xsl:text>ET  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- "Available Open Access" + dc.type.version + "at" + dc.identifier.uri -->
        <xsl:if test="($type = 'Article' or $type = 'Book Part' or $type = 'Conference Object') and doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']">
            <xsl:text>N1  - Available Open Access </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> at </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- Periodical Part note: tub.series.name + " ; " + tub.series.issuenumber -->
        <xsl:if test="not($type = 'Article' or $type = 'Book' or $type = 'Book Part' or $type = 'Doctoral Thesis' 
                          or $type = 'Habilitation' or $type = 'Master Thesis' or $type = 'Conference Proceedings'
                          or $type = 'Conference Object' or $type = 'Report' or $type = 'Research Paper' or $type = 'Preprint')
                      and (doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']
                      and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber'])"> 
            <xsl:text>N1  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> ; </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>         
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- Preprint note: dc.type + tub.publisher.universityorinstitution -->
        <xsl:if test="$type = 'Preprint'
                      and doc:metadata/doc:element[@name='dc']/doc:element[@name='type']
                      and doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']"> 
            <xsl:text>N1  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
            <xsl:text> </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>         
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.language.iso -->     
        <xsl:text>LA  - </xsl:text> 
        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']/text()"></xsl:value-of>
        <xsl:value-of select="$newline"></xsl:value-of>
        
        <!-- dc.description.abstract --> 
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']">
            <xsl:text>AB  - </xsl:text>
            <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']"></xsl:value-of>
            <xsl:value-of select="$newline"></xsl:value-of>
        </xsl:if>
        
        <!-- dc.subject.other -->
        <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']">
            <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']/doc:element/doc:field[@name='value']">
                <xsl:text>KW  - </xsl:text>
                <xsl:value-of select="."></xsl:value-of>
                <xsl:value-of select="$newline"></xsl:value-of>
            </xsl:for-each>
        </xsl:if>
        
        <!-- End of Reference (must be empty and the last tag)-->	
        <xsl:text>ER  - </xsl:text> 
        		
    </xsl:template>
    
</xsl:stylesheet>