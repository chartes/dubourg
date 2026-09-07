<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:dts="https://w3id.org/dts/api#"
  exclude-result-prefixes="tei dts">

  <xsl:import href="../hteiml/xsl/tei2html.xsl"/>

  <!--
    Surcharge Du Bourg.

    Le projet n'avait aucune XSL propre : il tombait sur le HTEIML générique, qui
    ne connaît ni l'élément non-TEI <nota> (extension Diple), ni <opener>, ni les
    listes d'index <listPerson>/<listPlace>. Ces éléments ressortaient donc en
    « balises d'erreur » rouges (<b style="color:red">&lt;listPerson&gt;</b>) :
    4 122 occurrences sur les 102 pages du corpus, dont les deux pages d'index
    entièrement illisibles. De plus, <persName ref="#X"> / <placeName ref="#X">
    perdaient leur lien : le HTEIML produisait un <a> SANS href.

    Référence de rendu : l'ÉLEC historique
    (http://elec.enc.sorbonne.fr/dubourg/l1, .../back-1-1, .../back-1-2).
  -->

  <!-- Identifiants DTS des deux pages d'index. Lorsque la liste est présente dans
       l'arbre transformé (rendu du document entier) on lit son @xml:id ; sur un
       fragment isolé (une lettre) elle est hors de portée, d'où le repli sur la
       valeur du document. -->
  <xsl:variable name="index-person-id">
    <xsl:choose>
      <xsl:when test="//tei:listPerson/@xml:id">
        <xsl:value-of select="//tei:listPerson/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>r15496</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="index-place-id">
    <xsl:choose>
      <xsl:when test="//tei:listPlace/@xml:id">
        <xsl:value-of select="//tei:listPlace/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>r17361</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="doc-base"
    select="'/dubourg/document/dubourg_correspondance?refId='"/>

  <!-- ====================================================================
       1) Renvois vers les index (ÉLEC : <a href="back-1-1#Roussy">…</a>)
       ==================================================================== -->
  <!-- Certains @ref du corpus omettent le croisillon (ref="Daugerant" au lieu de
       ref="#Daugerant") : on le normalise, sinon l'ancre est collée au refId. -->
  <xsl:template name="index-anchor">
    <xsl:choose>
      <xsl:when test="starts-with(@ref, '#')"><xsl:value-of select="@ref"/></xsl:when>
      <xsl:otherwise><xsl:text>#</xsl:text><xsl:value-of select="@ref"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:persName[@ref]" priority="20">
    <xsl:variable name="anchor"><xsl:call-template name="index-anchor"/></xsl:variable>
    <a property="dbo:person" class="persName"
       href="{$doc-base}{$index-person-id}{$anchor}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <xsl:template match="tei:placeName[@ref]" priority="20">
    <xsl:variable name="anchor"><xsl:call-template name="index-anchor"/></xsl:variable>
    <a property="dbo:place" class="placeName"
       href="{$doc-base}{$index-place-id}{$anchor}">
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- ====================================================================
       2) <nota> : élément non-TEI propre à Diple. ÉLEC rend
          « [<i>adresse au dos</i>] À monsr le chancellier. »
       ==================================================================== -->
  <xsl:template match="*[local-name() = 'nota']" priority="20">
    <div class="nota">
      <xsl:if test="@type">
        <xsl:attribute name="data-type"><xsl:value-of select="@type"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space(@desc) != ''">
        <xsl:text>[</xsl:text>
        <i class="nota-desc"><xsl:value-of select="normalize-space(@desc)"/></i>
        <xsl:text>] </xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- ====================================================================
       3) <opener> / <closer> : ÉLEC les rend comme des paragraphes de
          transcription (leur enfant <salute> est déjà géré par le HTEIML).
       ==================================================================== -->
  <xsl:template match="tei:opener" priority="20">
    <!-- <div> et non <p> : le HTEIML rend <salute> comme un <div>, qu'un <p>
         ne peut pas contenir (le navigateur refermerait le paragraphe). -->
    <div class="transcription opener"><xsl:apply-templates/></div>
  </xsl:template>

  <xsl:template match="tei:closer" priority="20">
    <div class="transcription closer"><xsl:apply-templates/></div>
  </xsl:template>

  <!-- ====================================================================
       4) Index des noms de personnes (ÉLEC : back-1-1)
       ==================================================================== -->
  <xsl:template match="tei:listPerson" priority="20">
    <div id="index-person">
      <ul class="index-list">
        <xsl:apply-templates select="tei:person"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="tei:person" priority="20">
    <li class="index-entry">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <span class="name index-name"><xsl:apply-templates select="tei:persName/node()"/></span>
      <xsl:if test="tei:birth | tei:death">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="normalize-space(tei:birth)"/>
        <xsl:if test="tei:birth and tei:death"><xsl:text> – </xsl:text></xsl:if>
        <xsl:if test="tei:death and not(tei:birth)"><xsl:text>† </xsl:text></xsl:if>
        <xsl:value-of select="normalize-space(tei:death)"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="tei:event"/>
    </li>
  </xsl:template>

  <xsl:template match="tei:event" priority="20">
    <div class="index-notice"><xsl:apply-templates/></div>
  </xsl:template>

  <!-- ====================================================================
       5) Index des noms de lieux (ÉLEC : back-1-2)
          « Ablon-sur-Seine, Val-de-Marne, arr. Créteil, cant. Villeneuve-le-Roi. »
          Les mentions déjà rédigées (« ch.-l. d'arr. ») ne reçoivent pas de
          préfixe, comme sur le site historique.
       ==================================================================== -->
  <xsl:template match="tei:listPlace" priority="20">
    <div id="index-place">
      <ul class="index-list">
        <xsl:apply-templates select="tei:place"/>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="tei:place" priority="20">
    <li class="index-entry">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <span class="name index-name"><xsl:apply-templates select="tei:placeName/node()"/></span>
      <xsl:apply-templates select="tei:location"/>
      <xsl:text>.</xsl:text>
    </li>
  </xsl:template>

  <xsl:template match="tei:location" priority="20">
    <span class="index-location">
      <xsl:for-each select="tei:district | tei:settlement | tei:region | tei:country">
        <xsl:text>, </xsl:text>
        <xsl:variable name="txt" select="normalize-space(.)"/>
        <xsl:choose>
          <xsl:when test="@type = 'arrondissement' and not(starts-with($txt, 'ch.-l.'))">
            <xsl:text>arr. </xsl:text>
          </xsl:when>
          <xsl:when test="@type = 'canton' and not(starts-with($txt, 'ch.-l.'))">
            <xsl:text>cant. </xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$txt"/>
      </xsl:for-each>
    </span>
  </xsl:template>

</xsl:transform>
