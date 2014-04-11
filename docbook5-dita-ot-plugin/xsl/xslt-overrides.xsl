<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://docbook.org/ns/docbook" xmlns:xlink="http://www.w3.org/1999/xlink">

<xsl:import href="map2docbook.xsl"/>


    <!-- ********************************** -->
    <!-- Remove xtrf and xtrc attributes from tbody and row elements.  -->
    <!-- ********************************** -->

  <xsl:template name="copyAs">
      <xsl:param name="elementName" select="local-name(.)"/>
      <xsl:param name="hasRemap"    select="true()"/>
      <xsl:element name="{$elementName}">
        <xsl:call-template name="copy.attributes">
            <xsl:with-param name="hasRemap" select="$hasRemap" />
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:template>
    
    <xsl:template name="copy.attributes">
        <xsl:param name="hasRemap" select="true()"/>
        <xsl:for-each select="@*">
          <xsl:choose>
              <xsl:when test="local-name(.) = 'spec'">
                <xsl:if test="$hasRemap">
                  <xsl:attribute name="remap">
                    <xsl:value-of select="."/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:when test="local-name(.) = ('class', 'xtrf', 'xtrc')"><!-- Added 'xtrf', 'xtrc' which don't belong in DocBook -->
              </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Change the value of the imagedata element align attribute from "left-justified" to "left".  -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/image ')]">
      <mediaobject>
        <xsl:call-template name="setStandardAttr">
          <xsl:with-param name="IDPrefix" select="'img'"/>
        </xsl:call-template>
        <imageobject>
          <imagedata>
            <xsl:if test="@href">
              <xsl:attribute name="fileref">
                <xsl:value-of select="@href"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@height">
              <xsl:attribute name="depth">
                <xsl:value-of select="@height"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@width">
              <xsl:attribute name="width">
                <xsl:value-of select="@width"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@align">
              <xsl:variable name="align.attr.value" select="@align" />
              <xsl:attribute name="align">
                <xsl:choose>
                    <xsl:when test="contains($align.attr.value, 'left-justified')">
                        <xsl:text>left</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@align"/>
                    </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@placement" mode="deflate"/>
          </imagedata>
        </imageobject>
        <xsl:if test="@alt or @longdescref">
          <textobject remap="alt_attribute">
            <xsl:if test="@alt">
              <phrase remap="#PCDATA">
                <xsl:value-of select="@alt"/>
              </phrase>
            </xsl:if>
            <xsl:if test="@longdescref">
              <xref linkend="{@href}">
                <xsl:call-template name="setStandardAttr">
                  <xsl:with-param name="IDPrefix" select="'xref'"/>
                </xsl:call-template>
              </xref>
            </xsl:if>
          </textobject>
        </xsl:if>
      </mediaobject>
    </xsl:template>

    <!-- ********************************** -->
    <!-- Don't render sections as sidebar elements.  -->
    <!-- ********************************** -->

    
    <xsl:template name="makeBlockCont">
      <xsl:param name="titleSpec" select="' topic/title '"/>
      <xsl:param name="titleNode" select="*[contains(@class,$titleSpec)]"/>
      <xsl:param name="isContReq" select="false()"/>
      <xsl:param name="IDPrefix"/>
      <xsl:variable name="hasBlocks">
        <xsl:call-template name="isBlock">
          <xsl:with-param name="nodelist" select="*"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
      <xsl:when test="$hasBlocks=1">
        <xsl:choose>
        <xsl:when test="$isContReq or $titleNode">
         <xsl:choose>
          <xsl:when test="count(*[not(contains(@class,$titleSpec))]) = count(*[contains(@class,' topic/qalist ')])">
            <qandaset>
              <xsl:call-template name="setStandardAttr">
                <xsl:with-param name="IDPrefix" select="$IDPrefix"/>
              </xsl:call-template>
              <xsl:if test="$titleNode">
                <xsl:apply-templates select="$titleNode"/>
              </xsl:if>
              <xsl:apply-templates select="*[contains(@class,' topic/qalist ')]">
                <xsl:with-param name="element" select="'qandadiv'"/>
              </xsl:apply-templates>
            </qandaset>
          </xsl:when>
          <xsl:otherwise>
            <!-- probably need to add other mappings -->
            <xsl:variable name="element">
              <xsl:text>section</xsl:text><!-- Changed this from sidebar to section. It's possible that this is wrong in some cases. -->
            </xsl:variable>
            <xsl:element name="{$element}">
              <xsl:call-template name="setStandardAttr">
                <xsl:with-param name="IDPrefix" select="$IDPrefix"/>
              </xsl:call-template>
              <xsl:if test="$titleNode">
                <xsl:apply-templates select="$titleNode"/>
              </xsl:if>
              <xsl:call-template name="makeBlockList">
                <xsl:with-param name="nodelist"
                    select="*[not(contains(@class,$titleSpec))]|text()"/>
              </xsl:call-template>
            </xsl:element>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="deflateBlock">
            <xsl:with-param name="nodelist"
                select="*[not(contains(@class,$titleSpec))]|text()"/>
          </xsl:call-template>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="makePara">
          <xsl:with-param name="titleSpec" select="$titleSpec"/>
          <xsl:with-param name="titleNode" select="$titleNode"/>
          <xsl:with-param name="IDPrefix"  select="$IDPrefix"/>
        </xsl:call-template>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:template>

    <!-- ********************************** -->
    <!-- If there are more than one title in an element, make all but the first bridgehead elements.  -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/title ')]">
      <xsl:param name="element"><!-- Added choose block to provide an alternate default value when one of the preceding sibling elements is a title. -->
        <xsl:variable name="total.preceding.titles" select="count(preceding-sibling::*[contains(@class,' topic/title ')])" />
        <xsl:choose>
            <xsl:when test="$total.preceding.titles > 0">
                <xsl:text>bridgehead</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>title</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
      </xsl:param>
      <xsl:param name="IDPrefix" select="'ttl'"/>
      <xsl:element name="{$element}">
        <xsl:call-template name="setStandardAttr">
          <xsl:with-param name="IDPrefix" select="$IDPrefix"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Don't create duplicate IDs for elements in the DocBook output.  -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/topic ')]">
      <xsl:param name="childrefs"/>
      <xsl:param name="element" select="'section'"/>
      <xsl:param name="map.gen.id" />
      <xsl:element name="{$element}">
        <xsl:call-template name="setStandardAttr">
          <xsl:with-param name="IDPrefix" select="''"/>
          <!-- <xsl:with-param name="map.gen.id" select="$map.gen.id" /> -->
        </xsl:call-template>
        <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
        <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]">
          <xsl:with-param name="contextType" select="$element"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="*[not(contains(@class, ' topic/prolog ')) and not(contains(@class, ' topic/title '))]"/>
        <xsl:if test="$childrefs">
          <xsl:apply-templates select="$childrefs"/>
        </xsl:if>
      </xsl:element>
    </xsl:template>
    
    <!--
    <xsl:template name="is.id.first">
        <xsl:variable name="current.id" select="generate-id()" />
        <xsl:choose>
            <xsl:when test="">
            </xsl:when>
            <xsl:otherwise />
        </xsl:choose>
    </xsl:template>
    -->
    
    <xsl:template name="setStandardAttr">
      <xsl:param name="IDPrefix" select="local-name(.)"/>
      <xsl:param name="map.gen.id" />
      <xsl:variable name="map.id.and.prefix">
        <xsl:choose>
            <xsl:when test="$map.gen.id != '' and not(contains(@class, ' topic/topic '))">
                <xsl:value-of select="$map.gen.id" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$IDPrefix" />
            </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="not( @id )">
        <!-- Don't generate an ID if there isn't one. Doing that causes problems when a file is included more than once. -->
        <!-- <xsl:attribute name="xml:id">
          <xsl:if test="$map.gen.id">
              <xsl:message>Prepending to an ID: <xsl:value-of select="." /></xsl:message>
              <xsl:value-of select="generate-id()" />
              <xsl:text>_</xsl:text>
          </xsl:if>
          <xsl:call-template name="provideID">
            <xsl:with-param name="IDPrefix" select="$IDPrefix"/>
          </xsl:call-template>
        </xsl:attribute> -->
      </xsl:if>
      <xsl:attribute name="remap">
        <xsl:value-of select="local-name(.)"/>
      </xsl:attribute>
      <xsl:for-each select="@*">
        <xsl:call-template name="testStandardAttr">
          <xsl:with-param name="IDPrefix" select="$map.id.and.prefix"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Use the xml namespace for id attributes  -->
    <!-- ********************************** -->
    
    <xsl:template name="testStandardAttr">
      <xsl:param name="IDPrefix"/>
      <xsl:param name="attrName" select="local-name(.)"/>
      <xsl:param name="map.gen.id" tunnel="yes"/>
      <xsl:choose>
      <xsl:when test="$attrName='id'">
        <xsl:attribute name="xml:id">
          <!-- When writing an ID, prepend the parent element's xtrf filename. Xrefs are doing the 
               same thing so this should match up. This is necessary because top-level elements in 
               different source files share the same ID values. Prepending the filename makes them 
               unique in the resulting DocBook file. -->
          <xsl:variable name="xtrf.value">
            <xsl:choose>
                <xsl:when test="contains(parent::*/@xtrf, '\')">
                    <!-- <xsl:message>ELEMENT xtrf includes backslash. Reduced: <xsl:value-of select="tokenize(parent::*/@xtrf, '\\')[last()]" /></xsl:message> -->
                    <xsl:value-of select="tokenize(parent::*/@xtrf, '\\')[last()]" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- <xsl:message>ELEMENT xtrf filename only: <xsl:value-of select="parent::*/@xtrf" /></xsl:message> -->
                    <xsl:value-of select="parent::*/@xtrf" />
                </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="$xtrf.value" />
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$attrName='spec'">
        <xsl:attribute name="remap">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$attrName='platform'">
        <xsl:attribute name="arch">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$attrName='product'">
        <xsl:attribute name="os">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$attrName='version'">
        <xsl:attribute name="revision">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="$attrName='audience'">
        <xsl:attribute name="userlevel">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:when>
      <!-- leave non-standard attributes to be handled locally -->
      </xsl:choose>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Use info elements rather than element-specific info elements such as sectioninfo.  -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/prolog ')]">
      <xsl:param name="contextType" select="'section'"/>
      <xsl:variable name="shortDescNode"
          select="../*[contains(@class,' topic/shortdesc ') or contains(@class, ' topic/abstract ')]"/>
      <xsl:variable name="prologNodes" select="*"/>
      <xsl:if test="$shortDescNode or $prologNodes">
        <xsl:variable name="elementName">
          <xsl:choose>
          <xsl:when test="$contextType='article'">artheader</xsl:when>
          <xsl:when test="$contextType='appendix'">docinfo</xsl:when>
          <xsl:when test="$contextType='book'">bookinfo</xsl:when>
          <xsl:when test="$contextType='chapter'">info</xsl:when>
          <xsl:when test="$contextType='glossary'">docinfo</xsl:when>
          <xsl:when test="$contextType='part'">docinfo</xsl:when>
          <xsl:when test="$contextType='section'">info</xsl:when><!-- removed "section" from "sectioninfo" -->
          <xsl:otherwise>
            <xsl:message>
              <xsl:text>Unknown context type </xsl:text>
              <xsl:value-of select="$contextType"/>
            </xsl:message>
            <xsl:text>sectioninfo</xsl:text>
          </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$elementName}">
          <xsl:call-template name="setStandardAttr">
            <xsl:with-param name="IDPrefix" select="'prlg'"/>
          </xsl:call-template>
          <xsl:apply-templates select="$shortDescNode" mode="abstract"/>
          <xsl:apply-templates select="$prologNodes"/>
        </xsl:element>
      </xsl:if>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Use XML namespace link instead of DocBook ulink element.  -->
    <!-- ********************************** -->
    
    <xsl:template match="*" mode="make-ulink-from-xref">
        <xsl:variable name="target">
            <xsl:value-of select="@href" />
        </xsl:variable>
        <xsl:element name="link">
            <xsl:attribute name="xlink:href" select="$target" />
        </xsl:element>
    </xsl:template>
    
    <!-- namespace="http://www.w3.org/1999/xlink" -->
    
    <!-- ********************************** -->
    <!-- Use replaceable element rather than DocBook varname.  -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' sw-d/varname ')]">
      <replaceable>
        <xsl:call-template name="setStandardAttr">
          <xsl:with-param name="IDPrefix" select="'vrnm'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
      </replaceable>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Write DocBook table entry elements rather than copying the DITA entry elements. -->
    <!-- DITA allows text nodes and p elements to be siblings in an entry element. DocBook 
         does not. Wrap text and inline elements in para elements. -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/entry ')]">
        <xsl:element name="entry">
            <xsl:call-template name="copy.attributes" />
            <xsl:choose>
                <!-- If the DITA entry includes a p element, we need to check for other 
                     content that needs to be wrapped in a sibling DocBook para element. 
                     Actually, wrap anything at all in a para. Removed this test content: *[contains(@class,' topic/p ')]-->
                <xsl:when test="node()">
                    <xsl:for-each-group select="node()" group-starting-with="*[contains(@class,' topic/p ')]">
                        <xsl:for-each select="current-group()">
                            <xsl:if test="self::*[contains(@class,' topic/p ')]">
                                <xsl:apply-templates select="." />
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:element name="para">
                            <xsl:for-each select="current-group()">
                                <xsl:if test="not(self::*[contains(@class,' topic/p ')])">
                                    <xsl:apply-templates select="." />
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:element>
                    </xsl:for-each-group>
                </xsl:when>
                <!-- But if there's no DITA p element, everything else can be a child of the DocBook entry element. -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:strip-space elements="entry" />
    
    <!-- ********************************** -->
    <!-- Don't write abstracts. -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/abstract ')]" mode="abstract" />
    <xsl:template match="*[contains(@class,' topic/abstract ')]" />
    <xsl:template match="*[contains(@class,' topic/shortdesc ')]" mode="abstract" />
    
    <!-- ********************************** -->
    <!-- Don't discard IDs that are not the first one in a file. -->
    <!-- ********************************** -->
    
    <xsl:template name="getLinkID">
      <xsl:param name="href" select="@href"/>
      <xsl:variable name="hasID" select="contains($href,'#')"/>
      <!-- If @href includes a file name and element ID, use only the filename part when referring to the file.  -->
      <xsl:variable name="linked.file">
        <xsl:choose>
            <xsl:when test="contains($href,'#')">
              <xsl:value-of select="substring-before(@href,'#')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$href"/>
            </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <!-- The top level element in the linked file contains an xtrf attribute that contains the 
           name of its source DITA file. That should be the same thing as the filename from this 
           href value but it might be more reliable to use the element's xtrf since the element will
           prepending the xtrf filename to its own ID. -->
      <xsl:variable name="linked.file.xtrf">
        <xsl:value-of select="document($linked.file, /)/*[contains(@class,' topic/topic ')]/@xtrf"/>
      </xsl:variable>
      <!-- Strip the filepath from the filename. We'll use only the file's name since that it probably 
           enough to make unique file/ID combinations. If that doesn't work the logic could include the 
           last few directories in the path. -->
      <xsl:variable name="file.name">
        <xsl:choose>
            <xsl:when test="contains($linked.file.xtrf, '\')">
                <!-- <xsl:message>XREF includes backslash: <xsl:value-of select="$linked.file.xtrf" /></xsl:message> -->
                <xsl:value-of select="tokenize($linked.file.xtrf, '\\')[last()]" />
            </xsl:when>
            <xsl:otherwise>
                <!-- <xsl:message>XREF filename only: <xsl:value-of select="$linked.file.xtrf" /> Element name: <xsl:value-of select="$href" /></xsl:message> -->
                <xsl:value-of select="$linked.file.xtrf" />
            </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- Prepend the source filename from the linked document's top level topic/topic element. -->
      <xsl:value-of select="$file.name" />
      <!-- Remove the filename from the href if there's a filename and ID. If there's only a filename, 
           take the ID from the top level topic/topic element. -->
      <xsl:choose>
        <xsl:when test="contains($href,'#') and contains(substring-after($href,'#'),'/')">
          <xsl:value-of select="substring-before(substring-after(@href,'#'),'/')"/>
        </xsl:when>
        <xsl:when test="contains($href,'#')">
          <xsl:value-of select="substring-after(@href,'#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="document($href, /)/*[contains(@class,' topic/topic ')]/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
    
    <!-- ********************************** -->
    <!-- Add tabstyle attribute to tables. Set to "content" if there's a thead element present, otherwise layout. -->
    <!-- ********************************** -->
    
    <xsl:template match="*[contains(@class,' topic/table ')]">
      <xsl:param name="titleSpec" select="' topic/title '"/>
      <xsl:param name="titleNode" select="*[contains(@class,$titleSpec)]"/>
      <xsl:variable name="descNode" select="*[contains(@class,' topic/desc ')]"/>
      <xsl:variable name="element">
        <xsl:choose>
        <xsl:when test="$titleNode">
          <xsl:text>table</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>informaltable</xsl:text>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="{$element}">
        <xsl:call-template name="setStandardAttr">
          <xsl:with-param name="IDPrefix" select="'tbl'"/>
        </xsl:call-template>
        <xsl:if test="@colsep">
          <xsl:copy-of select="@colsep"/>
        </xsl:if>
        <xsl:if test="@frame">
          <xsl:copy-of select="@frame"/>
        </xsl:if>
        <xsl:if test="@rowsep">
            <xsl:copy-of select="@rowsep"/>
        </xsl:if>
        <xsl:attribute name="tabstyle">
            <xsl:choose>
                <xsl:when test="self::*//*[contains(@class, 'topic/thead')]">
                    <xsl:text>content</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>layout</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates select="@rowheader|@scale" mode="deflate"/>
        <xsl:if test="$titleNode">
          <xsl:apply-templates select="$titleNode"/>
        </xsl:if>
        <xsl:if test="$descNode">
          <xsl:apply-templates select="$descNode"/>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class,' topic/tgroup ')]"/>
      </xsl:element>
    </xsl:template>

      
</xsl:stylesheet>