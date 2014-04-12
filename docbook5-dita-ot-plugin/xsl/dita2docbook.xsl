<?xml version="1.0" encoding="utf-8"?><!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.--><!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. --><xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://docbook.org/ns/docbook">

<xsl:import href="util.xsl"></xsl:import>
<xsl:import href="topic2db.xsl"></xsl:import>
<xsl:import href="highlight2db.xsl"></xsl:import>
<xsl:import href="programming2db.xsl"></xsl:import>
<xsl:import href="software2db.xsl"></xsl:import>
<xsl:import href="ui2db.xsl"></xsl:import>



<!--
<xsl:import href="xslt-overrides.xsl"/>
-->

<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   - DOCUMENT
   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<xsl:template match="/">
  <xsl:apply-templates></xsl:apply-templates>
</xsl:template>

<xsl:template match="dita">
  <section>
    <title></title>
    <xsl:apply-templates></xsl:apply-templates>
  </section>
</xsl:template>


</xsl:stylesheet>
