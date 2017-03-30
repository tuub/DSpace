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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" >


    <!--
        Recursive function searching for a DDC in a string.
        Example string 1: '153 Kognitive Prozesse, Intelligenz'
        Example string 2: 'DDC::300 Sozialwissenschaften::330 Wirtschaft::336 Öffentliche Finanzen'
        In the last case, we want the last DDC.
    -->
    <xsl:template name="find-ddc-recursively">
        <xsl:param name="text"/>
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="contains($text, '::')">
                <xsl:call-template name="find-ddc-recursively">
                    <xsl:with-param name="text" select="substring-after($text, '::')"/>
                    <xsl:with-param name="mode" select="$mode"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="number(substring($text,1,3)) + 1"><!-- The +1 is a trick to make it accept the DDC 000 -->
                    <xsl:choose>
                        <xsl:when test="$mode = 'text'">
                            <xsl:value-of select="normalize-space(substring($text,4))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring($text,1,3)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    Implementation: Claudia Jürgens, TU Dortmund
    -->
    <xsl:template name="replace-string">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="with"/>
        <xsl:choose>
            <xsl:when test="contains($text,$replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$with"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="text"
                                    select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="with" select="$with"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- convert iso-639-1 2 letter code to iso-639-2 bibliographic 3 letter
    code based on http://en.wikipedia.org/wiki/List_of_ISO_639-2_codes Date 2014-06-18
    Implementation: Claudia Jürgens, TU Dortmund
    -->

    <xsl:template name="getThreeLetterCodeLanguage">
        <xsl:param name="lang2"/>
        <xsl:choose>
            <xsl:when test="$lang2 = 'de' ">
                <xsl:text>ger</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'en' ">
                <xsl:text>eng</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'aa' ">
                <xsl:text>aar</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ab' ">
                <xsl:text>abk</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'af' ">
                <xsl:text>afr</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ak' ">
                <xsl:text>aka</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sq' ">
                <xsl:text>alb</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'am' ">
                <xsl:text>amh</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ar' ">
                <xsl:text>ara</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'an' ">
                <xsl:text>arg</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hy' ">
                <xsl:text>arm</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'as' ">
                <xsl:text>asm</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'av' ">
                <xsl:text>ava</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ae' ">
                <xsl:text>ave</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ay' ">
                <xsl:text>aym</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'az' ">
                <xsl:text>aze</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ba' ">
                <xsl:text>bak</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bm' ">
                <xsl:text>bam</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'eu' ">
                <xsl:text>baq</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'be' ">
                <xsl:text>bel</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bn' ">
                <xsl:text>ben</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bh' ">
                <xsl:text>bih</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bi' ">
                <xsl:text>bis</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bo' ">
                <xsl:text>bod</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bs' ">
                <xsl:text>bos</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'br' ">
                <xsl:text>bre</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bg' ">
                <xsl:text>bul</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'my' ">
                <xsl:text>bur</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ca' ">
                <xsl:text>cat</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cs' ">
                <xsl:text>ces</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ch' ">
                <xsl:text>cha</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ce' ">
                <xsl:text>che</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'zh' ">
                <xsl:text>chi</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cu' ">
                <xsl:text>chu</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cv' ">
                <xsl:text>chv</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kw' ">
                <xsl:text>cor</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'co' ">
                <xsl:text>cos</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cr' ">
                <xsl:text>cre</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cy' ">
                <xsl:text>cym</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'cs' ">
                <xsl:text>cze</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'da' ">
                <xsl:text>dan</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'dv' ">
                <xsl:text>div</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nl' ">
                <xsl:text>dut</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'dz' ">
                <xsl:text>dzo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'el' ">
                <xsl:text>ell</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'eo' ">
                <xsl:text>epo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'et' ">
                <xsl:text>est</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'eu' ">
                <xsl:text>eus</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ee' ">
                <xsl:text>ewe</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fo' ">
                <xsl:text>fao</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fa' ">
                <xsl:text>fas</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fj' ">
                <xsl:text>fij</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fi' ">
                <xsl:text>fin</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fr' ">
                <xsl:text>fra</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fy' ">
                <xsl:text>fry</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ff' ">
                <xsl:text>ful</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ka' ">
                <xsl:text>geo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'gd' ">
                <xsl:text>gla</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ga' ">
                <xsl:text>gle</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'gl' ">
                <xsl:text>glg</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'gv' ">
                <xsl:text>glv</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'el' ">
                <xsl:text>gre</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'gn' ">
                <xsl:text>grn</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'gu' ">
                <xsl:text>guj</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ht' ">
                <xsl:text>hat</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ha' ">
                <xsl:text>hau</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'he' ">
                <xsl:text>heb</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hz' ">
                <xsl:text>her</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hi' ">
                <xsl:text>hin</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ho' ">
                <xsl:text>hmo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hr' ">
                <xsl:text>hrv</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hu' ">
                <xsl:text>hun</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'hy' ">
                <xsl:text>hye</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ig' ">
                <xsl:text>ibo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'is' ">
                <xsl:text>ice</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'io' ">
                <xsl:text>ido</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ii' ">
                <xsl:text>iii</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'iu' ">
                <xsl:text>iku</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ie' ">
                <xsl:text>iie</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ia' ">
                <xsl:text>ina</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'id' ">
                <xsl:text>ind</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ik' ">
                <xsl:text>ipk</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'is' ">
                <xsl:text>isl</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'it' ">
                <xsl:text>ita</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'jv' ">
                <xsl:text>jav</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ja' ">
                <xsl:text>jpn</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kl' ">
                <xsl:text>kal</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kn' ">
                <xsl:text>kan</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ks' ">
                <xsl:text>kas</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ka' ">
                <xsl:text>kat</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kr' ">
                <xsl:text>kau</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kk' ">
                <xsl:text>kaz</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'km' ">
                <xsl:text>khm</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ki' ">
                <xsl:text>kik</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'rw' ">
                <xsl:text>kin</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ky' ">
                <xsl:text>kir</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kv' ">
                <xsl:text>kom</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kg' ">
                <xsl:text>kon</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ko' ">
                <xsl:text>kor</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'kj' ">
                <xsl:text>kua</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ku' ">
                <xsl:text>kur</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lo' ">
                <xsl:text>lao</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'la' ">
                <xsl:text>lat</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lv' ">
                <xsl:text>lav</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'li' ">
                <xsl:text>lim</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ln' ">
                <xsl:text>lin</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lt' ">
                <xsl:text>lit</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lb' ">
                <xsl:text>ltz</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lu' ">
                <xsl:text>lub</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'lg' ">
                <xsl:text>lug</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mk' ">
                <xsl:text>mac</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mh' ">
                <xsl:text>mah</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ml' ">
                <xsl:text>mal</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mi' ">
                <xsl:text>mao</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mr' ">
                <xsl:text>mar</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ms' ">
                <xsl:text>may</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mk' ">
                <xsl:text>mkd</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mg' ">
                <xsl:text>mlg</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mt' ">
                <xsl:text>mit</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mn' ">
                <xsl:text>mon</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'mi' ">
                <xsl:text>mri</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ms' ">
                <xsl:text>msa</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'my' ">
                <xsl:text>mya</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'na' ">
                <xsl:text>nau</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nv' ">
                <xsl:text>nav</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nr' ">
                <xsl:text>nbl</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nd' ">
                <xsl:text>nde</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ng' ">
                <xsl:text>ndo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ne' ">
                <xsl:text>nep</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nl' ">
                <xsl:text>nld</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nn' ">
                <xsl:text>nno</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'nb' ">
                <xsl:text>nob</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'no' ">
                <xsl:text>nor</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ny' ">
                <xsl:text>nya</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'oc' ">
                <xsl:text>oci</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'oj' ">
                <xsl:text>oji</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'or' ">
                <xsl:text>ori</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'om' ">
                <xsl:text>orm</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'os' ">
                <xsl:text>oss</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'pa' ">
                <xsl:text>pan</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'fa' ">
                <xsl:text>per</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'pi' ">
                <xsl:text>pli</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'pl' ">
                <xsl:text>pol</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'pt' ">
                <xsl:text>por</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ps' ">
                <xsl:text>pus</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'qu' ">
                <xsl:text>que</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'rm' ">
                <xsl:text>roh</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ro' ">
                <xsl:text>ron</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'rn' ">
                <xsl:text>run</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ru' ">
                <xsl:text>rus</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sg' ">
                <xsl:text>sag</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sa' ">
                <xsl:text>san</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'si' ">
                <xsl:text>sin</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sk' ">
                <xsl:text>slo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sl' ">
                <xsl:text>slv</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'se' ">
                <xsl:text>sme</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sm' ">
                <xsl:text>smo</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sn' ">
                <xsl:text>sna</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sd' ">
                <xsl:text>snd</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'so' ">
                <xsl:text>som</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'st' ">
                <xsl:text>sot</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'es' ">
                <xsl:text>spa</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sq' ">
                <xsl:text>sqi</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sc' ">
                <xsl:text>srd</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sr' ">
                <xsl:text>srp</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ss' ">
                <xsl:text>ssw</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'su' ">
                <xsl:text>sun</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sw' ">
                <xsl:text>swa</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'sv' ">
                <xsl:text>swe</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ty' ">
                <xsl:text>tah</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ta' ">
                <xsl:text>tam</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tt' ">
                <xsl:text>tat</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'te' ">
                <xsl:text>tel</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tg' ">
                <xsl:text>tgk</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tl' ">
                <xsl:text>tgl</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'th' ">
                <xsl:text>tha</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'bo' ">
                <xsl:text>tib</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ti' ">
                <xsl:text>tir</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'to' ">
                <xsl:text>ton</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tn' ">
                <xsl:text>tsn</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ts' ">
                <xsl:text>tso</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tk' ">
                <xsl:text>tuk</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tr' ">
                <xsl:text>tur</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'tw' ">
                <xsl:text>twi</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ug' ">
                <xsl:text>uig</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'uk' ">
                <xsl:text>ukr</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'ur' ">
                <xsl:text>urd</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'uz' ">
                <xsl:text>uzb</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 've' ">
                <xsl:text>ven</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'vi' ">
                <xsl:text>vie</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'vo' ">
                <xsl:text>vol</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'wa' ">
                <xsl:text>wln</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'wo' ">
                <xsl:text>wol</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'xh' ">
                <xsl:text>xho</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'yi' ">
                <xsl:text>yid</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'yo' ">
                <xsl:text>yor</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'za' ">
                <xsl:text>zha</xsl:text>
            </xsl:when>
            <xsl:when test="$lang2 = 'zu' ">
                <xsl:text>zul</xsl:text>
            </xsl:when>

            <xsl:otherwise>
                <xsl:text>und</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>