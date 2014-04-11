<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- Changing back to original 1.0 ver.<xsl:stylesheet version="2.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://docbook.org/ns/docbook"> -->

<xsl:import href="/scratch/publishing/publishing-tools/docbook5-dita-ot-plugin/xsl/dita2docbook.xsl"/>

<xsl:output
    method="xml"
    indent="yes"
    omit-xml-declaration="no"
    standalone="no" />


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - MAP
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<xsl:variable name="id.references">
    <xsl:call-template name="build.original.id.reference" />
</xsl:variable>
   
<xsl:template match="/">
  <xsl:apply-templates>
    <xsl:with-param name="original.id.reference" tunnel="yes">
        <xsl:call-template name="build.original.id.reference" />
    </xsl:with-param>
  </xsl:apply-templates>
  <xsl:result-document href="id-reference.xml" method="xml">
    <xsl:apply-templates select="$id.references" mode="copy.all" />
  </xsl:result-document>
</xsl:template>

<xsl:template match="*[contains(@class,' map/map ')]">
  <xsl:element name="book">
    <xsl:attribute name="version">5.0</xsl:attribute>
    <xsl:attribute name="xml:lang">en</xsl:attribute>
    <xsl:attribute name="xml:id" select="@id" />
    
    <xsl:element name="info">
        <xsl:choose>
          <xsl:when test="*[contains(@class,' topic/title ')]">
            <title>
              <xsl:value-of select="*[contains(@class,' topic/title ')]"/>
            </title>
          </xsl:when>
          <xsl:when test="@title">
            <title>
                <xsl:value-of select="@title"/>
            </title>
          </xsl:when>
        </xsl:choose>
        <xsl:element name="copyright">
            <xsl:element name="year">
                <xsl:value-of select="*[contains(@class,'bookmap/bookmeta')]/*[contains(@class,'bookmap/bookrights')]/*[contains(@class,'bookmap/copyrfirst')]/*[contains(@class,'bookmap/year')]" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="*[contains(@class,'bookmap/bookmeta')]/*[contains(@class,'bookmap/bookrights')]/*[contains(@class,'bookmap/copyrlast')]/*[contains(@class,'bookmap/year')]" />
            </xsl:element>
            <xsl:element name="holder">
                <xsl:value-of select="*[contains(@class,'bookmap/bookmeta')]/*[contains(@class,'bookmap/bookrights')]/*[contains(@class,'bookmap/bookowner')]" />
            </xsl:element>
        </xsl:element>
    </xsl:element>
    
    <!-- doesn't handle reltables or topicgroups -->
    <xsl:apply-templates select="*[contains(@class,' map/topicref ')]"/>
  </xsl:element>
</xsl:template>

<xsl:template match="*[contains(@class,' map/topicref ') and not(contains(@class,'bookmap/notices'))]" name="topicref">
  <xsl:param name="map.gen.id" />
  <xsl:param name="element">
    <xsl:choose>
        <xsl:when test="contains(parent::*/@class, 'map/map') or contains(parent::*/@class, 'bookmap/bookmap')">
            <xsl:text>chapter</xsl:text>
        </xsl:when>
        <xsl:when test="contains(parent::*/@class, 'bookmap/preface')">
            <xsl:text>preface</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>section</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  <xsl:variable name="hrefValue">
    <xsl:choose>
      <xsl:when test="contains(@href, '#')">
        <xsl:value-of select="substring-before(@href, '#')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@href"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
      <xsl:when test="contains(@class,'bookmap/preface')">
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]"/>
      </xsl:when>
      <xsl:when test="$hrefValue and not($hrefValue='')">
        <xsl:apply-templates select="document($hrefValue, /)/*">
          <xsl:with-param name="element" select="$element"/>
          <xsl:with-param name="childrefs"
              select="*[contains(@class,' map/topicref ')]"/>
          <xsl:with-param name="map.gen.id" tunnel="yes">
            <xsl:value-of select="$map.gen.id" />
            <xsl:value-of select="generate-id()" />
            <xsl:text>.</xsl:text>
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:when test="@navtitle">
        <xsl:element name="{$element}">
          <title>
            <xsl:value-of select="@navtitle"/>
          </title>
          <xsl:apply-templates select="*[contains(@class,' map/topicref ')]"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="*[contains(@class,' map/topicref ')]"/>
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[contains(@class,'bookmap/booktitle')]" name="booktitle" />
<xsl:template match="*[contains(@class,'bookmap/bookmeta')]" name="bookmeta" />
<xsl:template match="*[contains(@class,'bookmap/notices')]" name="notices" />

</xsl:stylesheet>
