<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="tei">

  <!-- [v2 H1] La feuille historique importait Diple (../../diple/transform/tei_html.xsl). -->
  <xsl:import href="../../renderers/hteiml/xsl/tei2html.xsl"/>
  <!-- [v2 H4] Sans indent="no", l'indentation de la sortie coupe les mots (« iiii e d'aoust »). -->
  <xsl:output indent="no"/>

  <!--
    Surcharge Du Bourg.

    I.  Liens entre le texte et l'index : hteiml ne relie un nom à son entrée que si l'index
        est dans l'arbre transformé, ce qui n'est jamais le cas sur le fragment d'une lettre.
    II. Reprise de la feuille de l'ÉLEC historique
        (http://elec.enc.sorbonne.fr/dubourg/transform/dubourg_html.xsl), qui fixait les
        conventions d'édition des textes modernes demandées par O. Poncet. Les écarts avec
        l'original sont marqués [v2 Hn] ; les commentaires [VJ]/[CD] sont d'origine.
        [v2 H2] Le sommaire de Diple (mode « ul ») n'est pas repris : dots-vue fait le sien.
  -->

  <!-- ====================================================================
       I. Du texte vers l'index  [v2 H3 : faisait partie de Diple, pas de la feuille]
       ==================================================================== -->

  <!-- Identifiants DoTS des deux pages d'index. Ce sont ceux que DoTS calcule à l'ingestion
       (citeStructure en use="default", d'après le numéro de nœud) : ils changeront si le TEI
       change, tant que l'index n'a pas d'identifiant stable (use="@xml:id"). -->
  <xsl:variable name="index-personnes" select="'dubourg_correspondance_idx_person'"/>
  <xsl:variable name="index-lieux" select="'dubourg_correspondance_idx_place'"/>

  <!-- Le croisillon manque dans quelques @ref (ref="Daugerant") : on le retire s'il est là,
       pour écrire l'ancre de la même façon dans tous les cas. Les <rs> (« le cardinal »)
       disent par @type s'ils désignent une personne ou un lieu. -->
  <xsl:template match="tei:persName[@ref] | tei:placeName[@ref]
                       | tei:rs[@ref][@type = 'person' or @type = 'place']">
    <xsl:variable name="personne" select="boolean(self::tei:persName or @type = 'person')"/>
    <xsl:variable name="index">
      <xsl:choose>
        <xsl:when test="$personne"><xsl:value-of select="$index-personnes"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$index-lieux"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a>
      <xsl:choose>
        <xsl:when test="$personne">
          <xsl:attribute name="property">dbo:person</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="property">dbo:place</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="atts"/>
      <!-- Après « atts » : pour un @ref sans croisillon, hteiml y écrit href="Daugerant",
           qui remplacerait notre lien si on le posait avant. -->
      <xsl:attribute name="href">
        <xsl:value-of select="concat('?refId=', $index, '#', translate(@ref, '#', ''))"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </a>
  </xsl:template>

  <!-- ====================================================================
       II. Feuille historique de l'ÉLEC
       ==================================================================== -->

  <!-- [VJ]pourquoi inscrire l'argument en italique ? cf les conventions pour les autres éditions
    pattern génant pour la page d'accueil... -> [CD] demande d'O. Poncet, convention pour l'édition des textes modernes-->
  <xsl:template match="tei:argument">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>
  <xsl:template match="tei:argument/tei:p">
    <xsl:choose>
      <xsl:when test="@n">
      <i>
        <xsl:for-each select=".">
        <a href="{@corresp}"><xsl:value-of select="@n"/></a>
        <xsl:text>. </xsl:text>
      </xsl:for-each>
    <xsl:apply-templates/>
      </i>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select=".">
          <p><xsl:apply-templates/></p>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- [VJ]pourquoi centrer ? la convention qui prévaut jusqu'à pt ne convient pas ? cf poitou
    TODO : revoir le template docDate pour prendre en charge le lieu...
    [CD] demande d'O.Poncet, convention pour l'édition des textes modernes
  -->
  <xsl:template match="tei:docDate">
    <p class="date">
      <xsl:apply-templates select="./tei:date"/>
      <xsl:text>. — </xsl:text>
      <xsl:apply-templates select="./tei:placeName"/>
    </p>
  </xsl:template>

  <!-- inutile d'enchâsser ainsi les appels de templates ; pourquoi restructurer ainsi ? -->
  <xsl:template match="tei:div[@type='transcription']">
    <xsl:apply-templates select="./tei:nota[@type='adresse']"/>
    <xsl:apply-templates select="./tei:opener"/>
    <xsl:apply-templates select="./tei:p"/>
    <xsl:apply-templates select="./tei:table"/>
    <xsl:apply-templates select="./tei:closer"/>
    <xsl:apply-templates select="./tei:postscript"/>
    <xsl:apply-templates select="./tei:nota[@type='note']"/>
  </xsl:template>

  <xsl:template match="tei:div[@type='transcription']/tei:p">
    <xsl:for-each select=".">
      <p class="transcription" id="{@xml:id}">
        <xsl:if test="@n">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="@n"/>
          <xsl:text>.] </xsl:text>
        </xsl:if>
        <xsl:apply-templates/></p>
      </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:opener|tei:closer">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:salute|tei:dateline">
    <p class="transcription"><xsl:apply-templates/></p>
  </xsl:template>

  <!-- mise en petites cap de la signature comme annoncé dans le schéma.
    Là encore, et comme pour le fer à droite, il faut déléguer le travail à CSS -->
  <!-- [v2 H5] <name> n'est pas du HTML : <span>. -->
  <xsl:template match="tei:signed">
    <p class="signed"><span class="signed"><xsl:apply-templates/></span></p>
  </xsl:template>

  <xsl:template match="tei:nota|tei:postscript">
    <xsl:if test="@desc"><xsl:text>[</xsl:text>
    <i><xsl:value-of select="@desc"/></i>
    <xsl:text>] </xsl:text></xsl:if>
    <xsl:apply-templates/>
  </xsl:template>


  <xsl:template match="tei:listPerson">
    <div id="index-person">
      <ul>
        <xsl:for-each select="./tei:person">
          <xsl:sort order="ascending"/>
          <li id="{./@xml:id}">
            <xsl:apply-templates/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="tei:person">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- [v2 H5] <name style="font-variant:small-caps;"> : <span>, petites capitales en CSS. -->
  <xsl:template match="tei:person/tei:persName">
    <span class="index-name"><xsl:apply-templates/></span>
  </xsl:template>

  <xsl:template match="tei:birth">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:death">
    <xsl:if test="not(preceding-sibling::tei:birth)">
      <xsl:text>(</xsl:text>
    </xsl:if>
    <xsl:text> - </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="tei:event">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:listPlace">
    <div id="index-place">
      <ul>
        <xsl:for-each select="./tei:place">
          <xsl:sort order="ascending"/>
          <li id="{./@xml:id}">
            <xsl:apply-templates/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="tei:place">
    <xsl:apply-templates select="./tei:placeName"/>
    <xsl:apply-templates select="./tei:location"/>
    <xsl:apply-templates select="./tei:event"/>
  </xsl:template>

  <!-- [v2 H5] <name style="font-variant:small-caps;"> : <span>, petites capitales en CSS. -->
  <xsl:template match="tei:place/tei:placeName">
    <span class="index-name"><xsl:apply-templates/></span>
    <xsl:choose>
      <xsl:when test="following-sibling::tei:location"><xsl:text>, </xsl:text>
      </xsl:when>
      <xsl:otherwise>.</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:location">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:district|tei:country">
    <xsl:if test="@type='arrondissement' and not(contains(.,'ch'))">
      <xsl:text>arr. </xsl:text>
    </xsl:if>
    <xsl:if test="@type='canton' and not(contains(.,'ch'))">
      <xsl:text>cant. </xsl:text>
    </xsl:if>
    <xsl:if test="@type='province' and not(contains(.,'ch'))">
      <xsl:text>prov. </xsl:text>
    </xsl:if>
    <xsl:if test="@type='commune'">
      <xsl:text>comm. </xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="not(following-sibling::tei:district)">
        <!-- [v2 H6] Le TEI porte déjà le point final des abréviations (« ch.-l. de dép. ») :
             ne pas en ajouter un second. -->
        <xsl:if test="substring(normalize-space(.), string-length(normalize-space(.))) != '.'">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>, </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:transform>
