<?xml version="1.0" encoding="UTF-8" ?>
<!-- XMetaDissPlus Crosswalk for DNB deposit http://www.dspace.org/license/ 
	Developed by cjuergen 
	based on XMetaDissPlus Version 2.2 Date 2012-02-21 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:doc="http://www.lyncode.com/xoai" version="1.0" xmlns:xsk="http://www.w3.org/1999/XSL/Transform">

    <xsl:include href="../templates/tub_templates.xsl" />

    <xsl:output omit-xml-declaration="yes" method="xml" indent="yes"/>

    <xsl:template match="/">

        <xMetaDiss:xMetaDiss xmlns:xMetaDiss="http://www.d-nb.de/standards/xmetadissplus/"
                             xmlns:cc="http://www.d-nb.de/standards/cc/" xmlns:dc="http://purl.org/dc/elements/1.1/"
                             xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:dcterms="http://purl.org/dc/terms/"
                             xmlns:pc="http://www.d-nb.de/standards/pc/" xmlns:urn="http://www.d-nb.de/standards/urn/"
                             xmlns:hdl="http://www.d-nb.de/standards/hdl/" xmlns:doi="http://www.d-nb.de/standards/doi/"
                             xmlns:thesis="http://www.ndltd.org/standards/metadata/etdms/1.0/"
                             xmlns:ddb="http://www.d-nb.de/standards/ddb/"
                             xmlns:dini="http://www.d-nb.de/standards/xmetadissplus/type/"
                             xmlns="http://www.d-nb.de/standards/subject/"
                             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xsi:schemaLocation="http://www.d-nb.de/standards/xmetadissplus/  http://files.dnb.de/standards/xmetadissplus/xmetadissplus.xsd">

            <!-- 1. Titel dc.title to dc:title -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
                <dc:title xsi:type="ddb:titleISO639-2">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dc:title>
            </xsl:for-each>

            <!-- 1. Translated titel dc.title.translated to dc:title -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']/doc:element/doc:field[@name='value']">
                <dc:title xsi:type="ddb:titleISO639-2" ddb:type="translated">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dc:title>
            </xsl:for-each>

            <!-- 2. Subtitle dc.title.subtitle to dcterms:alternative -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='subtitle']/doc:element/doc:field[@name='value']">
                <dcterms:alternative xsi:type="ddb:talternativeISO639-2">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dcterms:alternative>
            </xsl:for-each>

            <!-- 2. Translated subtitle dc.title.translatedsubtitle to dcterms:alternative -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translatedsubtitle']/doc:element/doc:field[@name='value']">
                <dcterms:alternative xsi:type="ddb:talternativeISO639-2" ddb:type="translated">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dcterms:alternative>
            </xsl:for-each>

            <!-- 3. Urheber dc.contributor.author to dc:creator xsi:type="pc:MetaPers" -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
                <!-- only persons with forename and surname -->
                <xsl:if test="contains(., ',') = 'true' ">
                    <dc:creator xsi:type="pc:MetaPers">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:creator>
                </xsl:if>
            </xsl:for-each>

            <!-- 3.1.1.6. Organisation als Urheber dc.contributor.organisation to dc:creator xsi:type="pc:MetaPers" -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='organisation']/doc:element/doc:field[@name='value']">
                <dc:creator xsi:type="pc:MetaPers">
                    <pc:person>
                        <pc:name type="otherName" otherNameType="organisation">
                            <pc:organisationName>
                                <xsl:value-of select="."/>
                            </pc:organisationName>
                        </pc:name>
                    </pc:person>
                </dc:creator>
            </xsl:for-each>

            <!-- 4. Klassifikation/Thesaurus dc.subject.ddc to dc:subject xsi:type="xMetaDiss:DDC-SG" -->
            <!--
                The DDC in DepositOnce is usually not just a number but a number with a description.
                Occasionally it also has the prefix 'DDC::'.
                Since the XSLT engine lyncode uses apparently doesn't support XSLT 2.0, we cannot work with regular
                expressions to get the number, thus the solution beneath.
                With XSLT 2.0 we could simply use the following: replace(.,'^(DDC:*)?(\d{3}).*$','$2')
            -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='ddc']/doc:element/doc:field[@name='value']">
                <xsl:variable name="ddcnumber">
                    <xsl:call-template name="find-ddc-recursively">
                        <xsl:with-param name="text" select="text()"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string-length(normalize-space($ddcnumber)) = 3">
                    <dc:subject xsi:type="xMetaDiss:DDC-SG">
                        <xsl:value-of select="$ddcnumber"/>
                    </dc:subject>
                </xsl:if>
            </xsl:for-each>

            <!-- 6. Abstract dc.description.abstract to dcterms:abstract -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
                <dcterms:abstract xsi:type="ddb:contentISO639-2">
                    <xsl:attribute name="lang">
                        <xsl:call-template name="getThreeLetterCodeLanguage">
                            <xsl:with-param name="lang2" select="../@name"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </dcterms:abstract>
            </xsl:for-each>


            <!-- 7. Verbreitende Stelle - tub.publisher.universityorinstitution -->
            <dc:publisher xsi:type="cc:Publisher" type="dcterms:ISO3166" countryCode="DE">
                <xsl:if test="not(doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution'])">
                    <cc:universityOrInstitution>
                        <cc:name>Technische Universität Berlin</cc:name>
                        <cc:place>Berlin</cc:place>
                    </cc:universityOrInstitution>
                    <cc:address>Straße des 17. Juni 135, 10623 Berlin</cc:address>
                </xsl:if>
                <xsl:for-each
                        select="doc:metadata/doc:element[@name='tub']/doc:element[@name='publisher']/doc:element[@name='universityorinstitution']/doc:element/doc:field[@name='value']">
                    <cc:universityOrInstitution>
                        <cc:name><xsl:value-of select="."/></cc:name>
                        <cc:place>Berlin</cc:place>
                    </cc:universityOrInstitution>
                    <cc:address>
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'Universitätsverlag')">Fasanenstr. 88, 10623 Berlin</xsl:when>
                            <xsl:otherwise>Straße des 17. Juni 135, 10623 Berlin</xsl:otherwise>
                        </xsl:choose>
                    </cc:address>
                </xsl:for-each>
            </dc:publisher>

            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor.advisor to dc:contributor pc:Contributor thesis:role=advisor -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='advisor']/doc:element/doc:field[@name='value']">
                <!-- only persons with forename and surname -->
                <xsl:if test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="advisor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:if>
            </xsl:for-each>

            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor.referee to dc:contributor pc:Contributor thesis:role=referee -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='referee']/doc:element/doc:field[@name='value']">
                <!-- only persons with forename and surname -->
                <xsl:if test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="referee">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:if>
            </xsl:for-each>

            <!-- 8. Betreuer / Gutachter / Prüfungskommission dc.contributor.editor to dc:contributor pc:Contributor thesis:role=editor -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
                <!-- only persons with forename and surname -->
                <xsl:if test="contains(., ',') = 'true' ">
                    <dc:contributor xsi:type="pc:Contributor" thesis:role="editor">
                        <pc:person>
                            <pc:name type="nameUsedByThePerson">
                                <pc:foreName>
                                    <xsl:value-of select="normalize-space(substring-after(., ','))"/>
                                </pc:foreName>
                                <pc:surName>
                                    <xsl:value-of select="substring-before(., ',')"/>
                                </pc:surName>
                            </pc:name>
                        </pc:person>
                    </dc:contributor>
                </xsl:if>
            </xsl:for-each>

            <!-- 11 Datum der Promotion dc.date.accepted to dcterms:dateAccepted -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accepted']/doc:element/doc:field[@name='value']">
                <dcterms:dateAccepted xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="."/>
                </dcterms:dateAccepted>
            </xsl:for-each>

            <!-- 12 Datum der Erstveröffentlichung dc.date.issued to dcterms:issued -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
                <dcterms:issued xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="."/>
                </dcterms:issued>
            </xsl:for-each>

            <!-- 14 Publikationstyp dc.type to dc:type xsi:type dini:PublType -->
            <!-- Modifying dc.type to suit the DINI "Gemeinsames Vokabular fuer Publikations- und Dokumentationstypen" -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
                <dc:type xsi:type="dini:PublType">
                    <xsl:choose>
                        <xsl:when test="string(text())='Animation'">MovingImage</xsl:when>
                        <xsl:when test="string(text())='Article'">article</xsl:when>
                        <xsl:when test="string(text())='Book'">book</xsl:when>
                        <xsl:when test="string(text())='Book chapter'">bookPart</xsl:when>
                        <xsl:when test="string(text())='Dataset'">ResearchData</xsl:when>
                        <xsl:when test="string(text())='Learning Object'">Other</xsl:when>
                        <xsl:when test="string(text())='Image'">Image</xsl:when>
                        <xsl:when test="string(text())='Image, 3-D'">Image</xsl:when>
                        <xsl:when test="string(text())='Map'">CarthographicMaterial</xsl:when>
                        <xsl:when test="string(text())='Musical Score'">MusicalNotation</xsl:when>
                        <xsl:when test="string(text())='Plan or blueprint'">Other</xsl:when>
                        <xsl:when test="string(text())='Preprint'">preprint</xsl:when>
                        <xsl:when test="string(text())='Presentation'">Other</xsl:when>
                        <xsl:when test="string(text())='Recording, acoustical'">Sound</xsl:when>
                        <xsl:when test="string(text())='Recording, musical'">Sound</xsl:when>
                        <xsl:when test="string(text())='Recording, oral'">Sound</xsl:when>
                        <xsl:when test="string(text())='Software'">Software</xsl:when>
                        <xsl:when test="string(text())='Technical Report'">report</xsl:when>
                        <xsl:when test="string(text())='Thesis'">StudyThesis</xsl:when>
                        <xsl:when test="string(text())='Video'">MovingImage</xsl:when>
                        <xsl:when test="string(text())='Working Paper'">workingPaper</xsl:when>
                        <xsl:when test="string(text())='Other'">Other</xsl:when>

                        <!-- TU Berlin specific document types -->
                        <xsl:when test="string(text())='Book Part'">bookPart</xsl:when>
                        <xsl:when test="string(text())='Conference Object'">conferenceObject</xsl:when>
                        <xsl:when test="string(text())='Conference Proceedings'">book</xsl:when>
                        <xsl:when test="string(text())='Doctoral Thesis'">doctoralThesis</xsl:when>
                        <xsl:when test="string(text())='Master Thesis'">masterThesis</xsl:when>
                        <xsl:when test="string(text())='Bachelor Thesis'">bachelorThesis</xsl:when>
                        <xsl:when test="string(text())='Multimedia'">Other</xsl:when>
                        <xsl:when test="string(text())='Periodical'">Periodical</xsl:when>
                        <xsl:when test="string(text())='Periodical Part'">PeriodicalPart</xsl:when>
                        <xsl:when test="string(text())='Habilitation'">doctoralThesis</xsl:when>
                        <xsl:when test="string(text())='Report'">report</xsl:when>
                        <xsl:when test="string(text())='Research Paper'">workingPaper</xsl:when>
                        <xsl:when test="string(text())='Generic Research Data'">ResearchData</xsl:when>
                        <xsl:when test="string(text())='Audio'">Sound</xsl:when>
                        <xsl:when test="string(text())='Video'">MovingImage</xsl:when>

                        <xsl:otherwise>Other</xsl:otherwise>
                    </xsl:choose>
                </dc:type>
            </xsl:for-each>

            <!-- 15 Publikations-Version dc.type.version to dini:version_driver -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field[@name='value']">
                <dini:version_driver>
                    <xsl:value-of select="."/>
                </dini:version_driver>
            </xsl:for-each>

            <!-- 16 Identifikator field handle to dc:identifier xsi:type="hdl" -->
            <!--xsl:for-each
                    select="doc:metadata/doc:element[@name='others']/doc:field[@name='handle']">
                <dc:identifier xsi:type="hdl:hdl">
                    <xsl:value-of select="."/>
                </dc:identifier>
            </xsl:for-each-->

            <!-- 16 Identifikator field handle to dc:identifier xsi:type="doi:doi" or xsi:type="urn:nbn" -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
                <xsl:if test="contains(., '10.14279')">
                    <dc:identifier xsi:type="doi:doi">
                        <xsl:value-of select="substring-after(., 'doi.org/')"/>
                    </dc:identifier>
                </xsl:if>
                <!--xsl:if test="starts-with(., 'urn:nbn')">
                    <dc:identifier xsi:type="urn:nbn">
                        <xsl:value-of select="."/>
                    </dc:identifier>
                </xsl:if-->
            </xsl:for-each>

            <!-- 20 Quelle der Hochschulschrift - if there is a print version, the ISBN can be referenced here: dc.identifier.isbn -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
                <dc:source xsi:type="ddb:ISBN">
                    <xsl:value-of select="."/>
                </dc:source>
            </xsl:for-each>
            
            <!-- 20 Quelle der Hochschulschrift - Journal data for articles -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value'] = 'Article'">
                <xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']">
                    <dc:source xsi:type="ddb:noScheme">
                        <xsl:value-of select="doc:element[@name='journaltitle']/doc:element/doc:field[@name='value']"/>
                        <xsl:if test="doc:element[@name='volume']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' ('"/>
                            <xsl:value-of select="doc:element[@name='volume']/doc:element/doc:field[@name='value']"/>
                            <xsl:value-of select="':'"/>
                            <xsl:value-of select="doc:element[@name='issue']/doc:element/doc:field[@name='value']"/>
                            <xsl:value-of select="')'"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='originalpublisherplace']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' - '"/><xsl:value-of select="doc:element[@name='originalpublisherplace']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' : '"/><xsl:value-of select="doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' - Art.-Id. '"/><xsl:value-of select="doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='pagestart']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' - S. '"/><xsl:value-of select="doc:element[@name='pagestart']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='pageend']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="'-'"/><xsl:value-of select="doc:element[@name='pageend']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                    </dc:source>
                </xsl:for-each>
            </xsl:if>

            <!-- 20 Quelle der Hochschulschrift - Book data for book part -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value'] = 'Book Part'">
                <xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']">
                    <dc:source xsi:type="ddb:noScheme">
                        <xsl:value-of select="doc:element[@name='booktitle']/doc:element/doc:field[@name='value']"/>
                        <xsl:if test="doc:element[@name='editor']">
                            <xsl:value-of select="' - Ed.: '"/>
                            <xsl:for-each select="doc:element[@name='editor']">
                                <xsl:value-of select="doc:element/doc:field[@name='value']"/><xsl:value-of select="';'"/>
                            </xsl:for-each>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='originalpublisherplace']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' - '"/><xsl:value-of select="doc:element[@name='originalpublisherplace']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' : '"/><xsl:value-of select="doc:element[@name='originalpublishername']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='pagestart']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="' - S. '"/><xsl:value-of select="doc:element[@name='pagestart']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                        <xsl:if test="doc:element[@name='pageend']/doc:element/doc:field[@name='value']">
                            <xsl:value-of select="'-'"/><xsl:value-of select="doc:element[@name='pageend']/doc:element/doc:field[@name='value']"/>
                        </xsl:if>
                    </dc:source>
                </xsl:for-each>
            </xsl:if>

            <!-- 20 Quelle der Hochschulschrift - Proceedings title for Conference Object -->
            <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value'] = 'Conference Object'">
                <xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='bibliographicCitation']/doc:element[@name='proceedingstitle']">
                    <dc:source xsi:type="ddb:noScheme">
                        <xsl:value-of select="doc:element/doc:field[@name='value']"/>
                    </dc:source>
                </xsl:for-each>
            </xsl:if>

            <!-- 21 Sprache der Hochschulschrift dc.language.iso to dc:language xsi:type="dcterms:ISO639-2" -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
                <dc:language xsi:type="dcterms:ISO639-2">
                    <xsl:call-template name="getThreeLetterCodeLanguage">
                        <xsl:with-param name="lang2" select="."/>
                    </xsl:call-template>
                </dc:language>
            </xsl:for-each>


            <!-- 23: dc.relation.isversionof to dcterms:isVersionOf -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isversionof']/doc:element/doc:field[@name='value']">

                <xsl:choose>
                    <xsl:when test="starts-with(., 'http')">
                        <dcterms:isVersionOf xsi:type="dcterms:URI">
                            <xsl:value-of select="."/>
                        </dcterms:isVersionOf>
                    </xsl:when>
                    <xsl:when test="starts-with(., '10.')">
                        <dcterms:isVersionOf xsi:type="dcterms:URI">
                            <xsl:value-of select="concat('https://doi.org/', .)"/>
                        </dcterms:isVersionOf>
                    </xsl:when>
                    <xsl:otherwise>
                        <dcterms:isVersionOf xsi:type="ddb:noScheme">
                            <xsl:value-of select="."/>
                        </dcterms:isVersionOf>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>


            <!-- 24: dc.relation.hasversion to dcterms:hasVersion -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='hasversion']/doc:element/doc:field[@name='value']">

                <xsl:choose>
                    <xsl:when test="starts-with(., 'http')">
                        <dcterms:hasVersion xsi:type="dcterms:URI">
                            <xsl:value-of select="."/>
                        </dcterms:hasVersion>
                    </xsl:when>
                    <xsl:when test="starts-with(., '10.')">
                        <dcterms:hasVersion xsi:type="dcterms:URI">
                            <xsl:value-of select="concat('https://doi.org/', .)"/>
                        </dcterms:hasVersion>
                    </xsl:when>
                    <xsl:otherwise>
                        <dcterms:hasVersion xsi:type="ddb:noScheme">
                            <xsl:value-of select="."/>
                        </dcterms:hasVersion>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>


            <!-- 29: dc.relation.ispartof to dcterms:isPartOf -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value']">

                <xsl:choose>
                    <xsl:when test="starts-with(., 'http')">
                        <dcterms:isPartOf xsi:type="dcterms:URI">
                            <xsl:value-of select="."/>
                        </dcterms:isPartOf>
                    </xsl:when>
                    <xsl:when test="starts-with(., '10.')">
                        <dcterms:isPartOf xsi:type="dcterms:URI">
                            <xsl:value-of select="concat('https://doi.org/', .)"/>
                        </dcterms:isPartOf>
                    </xsl:when>
                    <xsl:otherwise>
                        <dcterms:isPartOf xsi:type="ddb:noScheme">
                            <xsl:value-of select="."/>
                        </dcterms:isPartOf>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- 29: identifier for series (tub.series.name / issuenumber) - only for internal series -->
            <xsl:variable name="seriesname">
                <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='name']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>
            <!--
                DNB demands identifier for journals, we have none in the metadata. Workaround with mapping table.
                Unfortunately, we have in our data no distinction between series and journals, they are both in field tub.series.name.
                To differentiate between journals and series here, it is important, that there are only journals in this list!
            -->
            <xsl:variable name="journalzdbid">
                <xsl:choose>
                    <xsl:when test="$seriesname='adreizehn'">2812679-8</xsl:when>
                    <xsl:when test="$seriesname='Berliner Forum Gewaltprävention'">2513492-9</xsl:when>
                    <xsl:when test="$seriesname='Die Universitätsbibliothek der Technischen Universität Berlin : in den Jahren ..'">2829623-0</xsl:when>
                    <xsl:when test="$seriesname='Dokumente'">2807265-0</xsl:when>
                    <xsl:when test="$seriesname='IWB : Beiträge zur Wirtschaftspolitik'">2805058-7</xsl:when>
                    <xsl:when test="$seriesname='MSD : Masterstudium Denkmalpflege an der TU Berlin ; Jahrbuch'">2718391-9</xsl:when>
                    <xsl:when test="$seriesname='Preprint-Reihe des Instituts für Mathematik, Technische Universität Berlin'">2814965-8</xsl:when>
                    <xsl:when test="$seriesname='Rechenschaftsbericht / Technische Universität Berlin, Universitätsbibliothek'">2829623-0</xsl:when>
                    <xsl:when test="$seriesname='TU intern: die Hochschulzeitung der Technischen Universität Berlin'">2672493-5</xsl:when>
                    <xsl:when test="$seriesname='Wissen im Zentrum : Rechenschaftsbericht / Universitätsbibliothek, Technische Universität Berlin'">2829623-0</xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <!-- If there is an id for the series, it is a journal; should be displayed with Erstkat-ID and issuenumber in isPartOf, ddb::ZS-Ausgabe -->
                <xsl:when test="$journalzdbid != ''">
                    <dcterms:isPartOf xsi:type="ddb:Erstkat-ID">
                        <xsl:value-of select="$journalzdbid"/>
                    </dcterms:isPartOf>
                    <xsl:if test="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']">
                        <dcterms:isPartOf xsi:type="ddb:ZS-Ausgabe">
                            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']"/>
                        </dcterms:isPartOf>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <!-- If there is only a series name and issuenumber and no id, it should be displayed at length in isPartOf, ddb::noScheme -->
                    <xsl:if test="$seriesname != '' and doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']">
                        <dcterms:isPartOf xsi:type="ddb:noScheme">
                            <xsl:value-of select="$seriesname"/>
                            <xsl:text> ; </xsl:text>
                            <xsl:value-of select="doc:metadata/doc:element[@name='tub']/doc:element[@name='series']/doc:element[@name='issuenumber']/doc:element/doc:field[@name='value']"/>
                        </dcterms:isPartOf>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <!-- 30: dc.relation.haspart to dcterms:hasPart -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='haspart']/doc:element/doc:field[@name='value']">

                <xsl:choose>
                    <xsl:when test="starts-with(., 'http')">
                        <dcterms:hasPart xsi:type="dcterms:URI">
                            <xsl:value-of select="."/>
                        </dcterms:hasPart>
                    </xsl:when>
                    <xsl:when test="starts-with(., '10.')">
                        <dcterms:hasPart xsi:type="dcterms:URI">
                            <xsl:value-of select="concat('https://doi.org/', .)"/>
                        </dcterms:hasPart>
                    </xsl:when>
                    <xsl:otherwise>
                        <dcterms:hasPart xsi:type="ddb:noScheme">
                            <xsl:value-of select="."/>
                        </dcterms:hasPart>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- 32: dc.relation.references to dcterms:references -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='references']/doc:element/doc:field[@name='value']">

                <xsl:choose>
                    <xsl:when test="starts-with(., 'http')">
                        <dcterms:references xsi:type="dcterms:URI">
                            <xsl:value-of select="."/>
                        </dcterms:references>
                    </xsl:when>
                    <xsl:when test="starts-with(., '10.')">
                        <dcterms:references xsi:type="dcterms:URI">
                            <xsl:value-of select="concat('https://doi.org/', .)"/>
                        </dcterms:references>
                    </xsl:when>
                    <xsl:otherwise>
                        <dcterms:references xsi:type="ddb:noScheme">
                            <xsl:value-of select="."/>
                        </dcterms:references>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- 39: dc:rights uri -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
                <dc:rights xsi:type="dcterms:URI">
                    <xsl:value-of select="."/>
                </dc:rights>
            </xsl:for-each>

            <!-- 39: dc:rights other -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element[@name='other']/doc:element/doc:field[@name='value']">
                <dc:rights xsi:type="ddb:noScheme">
                    <xsl:value-of select="."/>
                </dc:rights>
            </xsl:for-each>

            <!-- dc.type.publicationtype to thesis.degree -->
            <!-- possible xmetadissplus types thesis.doctoral, thesis.habilitation, bachelor, master, post-doctoral, Staatsexamen, Diplom, Lizentiat, M.A., other -->
            <xsl:variable name="pType">
                <xsl:value-of
                        select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']"/>
            </xsl:variable>

            <xsl:if test="($pType = 'Doctoral Thesis')
							or ($pType = 'Habilitation')
							or ($pType = 'Master Thesis')
							or ($pType = 'Bachelor Thesis')">

                <xsl:variable name="grantor">
                    <xsl:value-of
                            select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='grantor']/doc:element/doc:field[@name='value']"/>
                </xsl:variable>
                <xsl:variable name="grantorName">
                    <xsl:choose>
                        <xsl:when test="$grantor = ''">
                            <xsl:text>Technische Universität Berlin</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains($grantor, ',')">
                            <xsl:value-of select="substring-before($grantor, ',')"/>
                        </xsl:when>
                        <xsl:otherwise><xsl:value-of select="$grantor"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <thesis:degree>
                    <thesis:level>
                        <xsl:choose>
                            <xsl:when test="$pType = 'Bachelor Thesis'">
                                <xsl:text>bachelor</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'Doctoral Thesis'">
                                <xsl:text>thesis.doctoral</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'Master Thesis'">
                                <xsl:text>master</xsl:text>
                            </xsl:when>
                            <xsl:when test="$pType = 'Habilitation'">
                                <xsl:text>thesis.habilitation</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </thesis:level>
                    <thesis:grantor xsi:type="cc:Corporate" type="dcterms:ISO3166" countryCode="DE">
                        <cc:universityOrInstitution>
                            <cc:name><xsl:value-of select="$grantorName"/></cc:name>
                            <cc:place>Berlin</cc:place>
                            <xsl:if test="substring-after($grantor, ',') != ''">
                                <cc:department>
                                    <cc:name><xsl:value-of select="normalize-space(substring-after($grantor, ','))"/></cc:name>
                                    <cc:place>Berlin</cc:place>
                                </cc:department>
                            </xsl:if>
                        </cc:universityOrInstitution>
                    </thesis:grantor>
                </thesis:degree>
            </xsl:if>


            <!-- amount of files based on the description DNB of the bitstreams in the bundle original to ddb:FileNumber -->

            <xsl:variable name="fileNumber">
                <xsl:value-of
                        select="count(/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream'])"/>
            </xsl:variable>

            <ddb:fileNumber>
                <xsl:value-of select="$fileNumber"/>
            </ddb:fileNumber>

            <!-- 44. File properties -->
            <xsl:for-each 
                    select="/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                
                <ddb:fileProperties>
                    <xsl:attribute name="ddb:fileName">
                        <xsl:value-of select="./doc:field[@name='name']"/>
                    </xsl:attribute>
                    <xsl:attribute name="ddb:fileSize">
                        <xsl:value-of select="./doc:field[@name='size']"/>
                    </xsl:attribute>
                </ddb:fileProperties>
            </xsl:for-each>

            <!-- ddb:transfer - normal bitstream link if 1 or special retrieve link > 1 -->
            <!-- the "url" in xoai assumes that dspace is deployed as root application -->
            <xsl:variable name="bundleName">
                <!-- If there is more than only one file, get the archive, otherwise the original bundle -->
                <xsl:choose>
                    <xsl:when test="$fileNumber > '1'">ARCHIVE</xsl:when>
                    <xsl:otherwise>ORIGINAL</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:for-each
                    select="/doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name' and text()=$bundleName]/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']">
                <!-- 45. Checksum -->
                <ddb:checksum>
                    <xsl:attribute name="ddb:type">
                        <xsl:value-of select="./doc:field[@name='checksumAlgorithm']"/>
                    </xsl:attribute>
                    <xsl:value-of select="./doc:field[@name='checksum']"/>
                </ddb:checksum>

                <!-- 46. Transfer-URL -->
                <ddb:transfer ddb:type="dcterms:URI">
                    <xsl:value-of select="./doc:field[@name='url']"/>
                </ddb:transfer>
            </xsl:for-each>

            <!-- 47. Further Identifier: urn, handle -->
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
                <xsl:if test="starts-with(., 'urn:nbn')">
                    <ddb:identifier ddb:type="URN">
                        <xsl:value-of select="."/>
                    </ddb:identifier>
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each
                    select="doc:metadata/doc:element[@name='others']/doc:field[@name='handle']">
                <ddb:identifier ddb:type="handle">
                    <xsl:value-of select="."/>
                </ddb:identifier>
            </xsl:for-each>


            <!-- 48. ddb:rights from metadata.tub.accessrights.dnb -->
            <xsl:variable name="accessrights" select="doc:metadata/doc:element[@name='tub']/doc:element[@name='accessrights']/doc:element[@name='dnb']/doc:element/doc:field[@name='value']"/>
            <ddb:rights>
                <xsl:attribute name="ddb:kind">
                <xsl:choose>
                    <xsl:when test="$accessrights">
                        <xsl:value-of select="$accessrights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'unknown'"/>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </ddb:rights>

            <!-- 50. ddb:server - default "Technische Universität Berlin" -->
            <ddb:server>
                <xsl:text>Technische Universität Berlin</xsl:text>
            </ddb:server>

        </xMetaDiss:xMetaDiss>
    </xsl:template>

</xsl:stylesheet>
