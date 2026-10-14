<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:tf="urn:elec:tableau-filtrable"
  exclude-result-prefixes="tei tf">

  <!-- ==== 0. DÉCLARATIONS : imports, sortie, paramètres, variables, clés, fonctions ==== -->

  <!-- [v2 H1] La feuille historique importait Diple (../../diple/transform/tei_html.xsl). -->
  <xsl:import href="../../renderers/hteiml/xsl/tei2html.xsl"/>

  <!-- Tableaux triables et filtrables : copie du module commun, à côté de la feuille. -->
  <xsl:import href="tableau-filtrable.xsl"/>

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

  <xsl:variable name="index-personnes" select="'dubourg_correspondance_idx_person'"/>

  <xsl:variable name="index-lieux" select="'dubourg_correspondance_idx_place'"/>

  <!-- IV. Index des lieux : même tableau que l'index des personnes (2026-10-13).
       Département ou pays : le district de type departement, sinon le pays ; le filtre en
       liste porte sur le département sans sa précision (« Somme » pour « Somme, ch.-l. de
       dép. ») ou sur le pays. Précisions : les autres districts (arr., cant., région,
       prov., comm.), le pays quand il y a aussi un département, et la notice éventuelle.
       Lettres : comme pour les personnes. -->
  <xsl:function name="dub:lieu-cle" as="xs:string" xmlns:dub="urn:dubourg:xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema">
    <xsl:param name="place" as="element()"/>
    <xsl:variable name="dep" select="normalize-space(string(dub:departement($place)))"/>
    <xsl:sequence select="if ($dep != '') then normalize-space(tokenize($dep, ',')[1]) else normalize-space(string(($place/tei:location/tei:country)[1]))"/>
  </xsl:function>

  <xsl:function name="dub:departement" as="element()?" xmlns:dub="urn:dubourg:xsl">
    <xsl:param name="place" as="element()"/>
    <xsl:sequence select="$place/tei:location/tei:district[@type = 'departement'][matches(normalize-space(.), '^\p{Lu}')][1]"/>
  </xsl:function>

  <!-- ==== 1. HISTORIQUE : surcharge reprise de la feuille de l'ÉLEC (rendu du texte de l'édition) ==== -->

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

  <!-- ==== 2. BLOCS HTEIML GÉNÉRIQUES : enveloppe dts:wrapper, notes, apparat critique, bibliographie (listBibl) ==== -->

  <!-- 2026-10-14 : enveloppe DoTS d'un fragment, transparente (sans modèle, hteiml
       l'affichait en span class="error", « <dts:wrapper> » en rouge en tête de page). -->
  <xsl:template match="*[local-name() = 'wrapper']">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- ==== 3. PROPRE AU PROJET ==== -->

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

  <!-- 2026-10-14 : présentation d'un groupe (« Enquête sur la Great Bible ») : un titre et des
       paragraphes, donc un bloc et non un <p> (un titre et des <p> dans un <p> : HTML invalide,
       cassé par le navigateur). Classe presentation et non argument : texte courant, pas le style
       des résumés de lettre (petit corps, italique, retrait). -->
  <xsl:template match="tei:argument[tei:head]" priority="2">
    <div class="presentation">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- 2026-10-14 : niveaux de titre d'une page de groupe : le titre du groupe en h1, celui de
       sa présentation et ceux de ses lettres en h2 (hteiml mettait tout en h1). Une lettre
       servie seule (sans groupe autour) garde son titre en h1. -->
  <xsl:template match="tei:argument/tei:head | tei:group//tei:text/tei:front/tei:head" priority="2">
    <h2 class="head"><xsl:apply-templates/></h2>
  </xsl:template>

  <!-- ====================================================================
       III. Index des personnes : tableau triable et filtrable (2026-10-13)
       Modèle : Montferrand (index des noms). Le module commun fournit barre, en-têtes et
       filtres (classes tf-*) ; la feuille ne pose que les classes dub-* et les données.
       Colonne « Lettres » : les renvois sont dans le TEI, sous chaque entrée de l'index
       (listRef type="lettres", un ref par lettre qui cite la personne ou le lieu) : la
       page d'index se suffit, sans relire le reste du corpus.
       ==================================================================== -->


  <xsl:template match="tei:listPerson">
    <xsl:variable name="max-lettres" select="max(for $p in tei:person return count($p/tei:listRef[@type = 'lettres']/tei:ref))"/>
    <div id="index-person">
      <div class="tf-cadre dub-tableau-cadre">
        <xsl:call-template name="tf-barre">
          <xsl:with-param name="total" select="count(tei:person)"/>
          <xsl:with-param name="unite" select="'personnes'"/>
        </xsl:call-template>
        <table class="dub-tableau dub-personnes" data-csv-nom="dubourg-personnes" data-csv-entetes="Nom|Dates|Notice|Lettres">
          <caption class="dub-tableau-legende">
            <xsl:text>Cliquer sur un en-tête de colonne pour trier (un second clic inverse l’ordre).</xsl:text>
          </caption>
          <thead>
            <tr>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-nom'"/><xsl:with-param name="libelle" select="'Nom'"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-dates'"/><xsl:with-param name="libelle" select="'Dates'"/><xsl:with-param name="numerique" select="true()"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-notice'"/><xsl:with-param name="libelle" select="'Notice'"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-lettres'"/><xsl:with-param name="libelle" select="'Lettres'"/><xsl:with-param name="numerique" select="true()"/></xsl:call-template>
            </tr>
            <tr class="tf-filtres dub-filtres">
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="0"/><xsl:with-param name="libelle" select="'Nom'"/><xsl:with-param name="liste" select="'dub-personnes-noms'"/><xsl:with-param name="suggestions" select="tei:person/tei:persName"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="1"/><xsl:with-param name="libelle" select="'Dates'"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="2"/><xsl:with-param name="libelle" select="'Notice'"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="3"/><xsl:with-param name="libelle" select="'Lettres'"/><xsl:with-param name="type" select="'intervalle'"/><xsl:with-param name="min" select="0"/><xsl:with-param name="max" select="$max-lettres"/></xsl:call-template>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="tei:person">
              <xsl:sort select="normalize-space(tei:persName)" collation="http://www.w3.org/2013/collation/UCA?lang=fr;strength=primary"/>
              <xsl:variable name="id" select="string(@xml:id)"/>
              <xsl:variable name="nom" select="normalize-space(tei:persName)"/>
              <xsl:variable name="naissance" select="normalize-space(tei:birth)"/>
              <xsl:variable name="mort" select="normalize-space(tei:death)"/>
              <xsl:variable name="dates" select="normalize-space(if ($naissance = '' and $mort = '') then '' else concat($naissance, ' – ', $mort))"/>
              <xsl:variable name="annee" select="if (matches($naissance, '[0-9]{4}')) then replace($naissance, '^[^0-9]*([0-9]{4}).*$', '$1') else ''"/>
              <xsl:variable name="lettres" select="tei:listRef[@type = 'lettres']/tei:ref"/>
              <tr id="{$id}" class="dub-ligne" data-o="{position()}">
                <td class="dub-c-nom" data-sort="{$nom}" data-f="{tf:plat(string($nom))}">
                  <xsl:apply-templates select="tei:persName"/>
                </td>
                <td class="dub-c-dates" data-sort="{$annee}" data-f="{tf:plat(string($dates))}">
                  <xsl:choose>
                    <xsl:when test="$dates != ''"><xsl:value-of select="$dates"/></xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
                <td class="dub-c-notice" data-sort="{normalize-space(string(tei:event))}" data-f="{tf:plat(string(tei:event))}">
                  <xsl:choose>
                    <xsl:when test="normalize-space(tei:event) != ''"><xsl:apply-templates select="tei:event/tei:p"/></xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
                <td class="dub-c-lettres" data-sort="{count($lettres)}" data-f="{string-join($lettres ! normalize-space(.), ' ')}">
                  <xsl:choose>
                    <xsl:when test="$lettres">
                      <xsl:for-each select="$lettres">
                        <xsl:if test="position() != 1"><xsl:text>, </xsl:text></xsl:if>
                        <a href="?refId={substring-after(@target, '#')}"><xsl:value-of select="normalize-space(.)"/></a>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </div>
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

  <xsl:template match="tei:listPlace" xmlns:dub="urn:dubourg:xsl">
    <xsl:variable name="uca" select="'http://www.w3.org/2013/collation/UCA?lang=fr;strength=primary'"/>
    <xsl:variable name="max-lettres" select="max(for $p in tei:place return count($p/tei:listRef[@type = 'lettres']/tei:ref))"/>
    <div id="index-place">
      <div class="tf-cadre dub-tableau-cadre">
        <xsl:call-template name="tf-barre">
          <xsl:with-param name="total" select="count(tei:place)"/>
          <xsl:with-param name="unite" select="'lieux'"/>
        </xsl:call-template>
        <table class="dub-tableau dub-lieux" data-csv-nom="dubourg-lieux" data-csv-entetes="Lieu|Département ou pays|Précisions|Lettres">
          <caption class="dub-tableau-legende">
            <xsl:text>Cliquer sur un en-tête de colonne pour trier (un second clic inverse l’ordre).</xsl:text>
          </caption>
          <thead>
            <tr>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-nom'"/><xsl:with-param name="libelle" select="'Lieu'"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-dep'"/><xsl:with-param name="libelle" select="'Département ou pays'"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-notice'"/><xsl:with-param name="libelle" select="'Précisions'"/></xsl:call-template>
              <xsl:call-template name="tf-th"><xsl:with-param name="classe" select="'dub-c-lettres'"/><xsl:with-param name="libelle" select="'Lettres'"/><xsl:with-param name="numerique" select="true()"/></xsl:call-template>
            </tr>
            <tr class="tf-filtres dub-filtres">
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="0"/><xsl:with-param name="libelle" select="'Lieu'"/><xsl:with-param name="liste" select="'dub-lieux-noms'"/><xsl:with-param name="suggestions" select="sort(distinct-values(tei:place/tei:placeName ! normalize-space(.)), $uca)"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="1"/><xsl:with-param name="libelle" select="'Département ou pays'"/><xsl:with-param name="type" select="'liste'"/><xsl:with-param name="tous" select="'Tous'"/><xsl:with-param name="options" select="sort(distinct-values(for $p in tei:place return dub:lieu-cle($p)[. != '']), $uca)"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="2"/><xsl:with-param name="libelle" select="'Précisions'"/></xsl:call-template>
              <xsl:call-template name="tf-filtre"><xsl:with-param name="col" select="3"/><xsl:with-param name="libelle" select="'Lettres'"/><xsl:with-param name="type" select="'intervalle'"/><xsl:with-param name="min" select="0"/><xsl:with-param name="max" select="$max-lettres"/></xsl:call-template>
            </tr>
          </thead>
          <tbody>
            <xsl:for-each select="tei:place">
              <xsl:sort select="normalize-space(tei:placeName)" collation="http://www.w3.org/2013/collation/UCA?lang=fr;strength=primary"/>
              <xsl:variable name="id" select="string(@xml:id)"/>
              <xsl:variable name="nom" select="normalize-space(tei:placeName)"/>
              <xsl:variable name="departement" select="dub:departement(.)"/>
              <xsl:variable name="dep" select="dub:lieu-cle(.)"/>
              <xsl:variable name="suite-dep" select="normalize-space(substring-after(string($departement), ','))"/>
              <xsl:variable name="cle" select="dub:lieu-cle(.)"/>
              <xsl:variable name="precisions" as="xs:string*" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                select="($suite-dep[. != ''],
                         for $d in tei:location/tei:district except $departement
                         return concat(if (contains($d, 'ch')) then ''
                                       else if ($d/@type = 'arrondissement') then 'arr. '
                                       else if ($d/@type = 'canton') then 'cant. '
                                       else if ($d/@type = 'province') then 'prov. '
                                       else if ($d/@type = 'commune') then 'comm. ' else '', normalize-space($d)),
                         if ($departement) then tei:location/tei:country ! normalize-space(.) else ())"/>
              <xsl:variable name="lettres" select="tei:listRef[@type = 'lettres']/tei:ref"/>
              <tr id="{$id}" class="dub-ligne" data-o="{position()}">
                <td class="dub-c-nom" data-sort="{$nom}" data-f="{tf:plat($nom)}">
                  <span class="index-name"><xsl:apply-templates select="tei:placeName/node()"/></span>
                </td>
                <td class="dub-c-dep" data-sort="{$cle}" data-f="{tf:plat($cle)}" data-csv="{$dep}">
                  <xsl:choose>
                    <xsl:when test="$dep != ''"><xsl:value-of select="$dep"/></xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
                <td class="dub-c-notice" data-sort="{string-join($precisions, ', ')}" data-f="{tf:plat(string-join(($precisions, string(tei:event)), ' '))}">
                  <xsl:choose>
                    <xsl:when test="exists($precisions) or normalize-space(tei:event) != ''">
                      <xsl:value-of select="string-join($precisions, ', ')"/>
                      <xsl:if test="exists($precisions) and normalize-space(tei:event) != ''"><xsl:value-of select="if (ends-with($precisions[last()], '.')) then ' ' else '. '"/></xsl:if>
                      <xsl:apply-templates select="tei:event/tei:p/node()"/>
                    </xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
                <td class="dub-c-lettres" data-sort="{count($lettres)}" data-f="{string-join($lettres ! normalize-space(.), ' ')}">
                  <xsl:choose>
                    <xsl:when test="$lettres">
                      <xsl:for-each select="$lettres">
                        <xsl:if test="position() != 1"><xsl:text>, </xsl:text></xsl:if>
                        <a href="?refId={substring-after(@target, '#')}"><xsl:value-of select="normalize-space(.)"/></a>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise><span class="tf-vide dub-vide">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </tbody>
        </table>
      </div>
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

  <!-- ==== 4. MÉCANISMES COMMUNS : tableau filtrable (tf-*), liens vers l'ancien site (D5), liens internes entre fragments ==== -->

  <!-- (aucun) -->

</xsl:transform>
