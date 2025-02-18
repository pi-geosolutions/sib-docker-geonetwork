<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:ogc="http://www.opengis.net/rdf#"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:geo="http://www.opengis.net/ont/geosparql#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:iso19139="http://geonetwork-opensource.org/schemas/iso19139"
                version="2.0"
                extension-element-prefixes="saxon" exclude-result-prefixes="#all">


  <!-- TODO : add Multilingual metadata support
    See http://www.w3.org/TR/2004/REC-rdf-syntax-grammar-20040210/#section-Syntax-languages

    TODO : maybe some characters may be encoded / avoid in URIs
    See http://www.w3.org/TR/2004/REC-rdf-concepts-20040210/#dfn-URI-reference
  -->

  <xsl:variable name="resourcePrefix"
                select="util:getSettingValue('metadata/resourceIdentifierPrefix')"/>

  <!--
    Create reference block to metadata record and dataset to be added in dcat:Catalog usually.
  -->
  <!-- FIME : $url comes from a global variable. -->
  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"
                mode="record-reference">
    <!-- TODO : a metadata record may contains aggregate. In that case create one dataset per aggregate member. -->
    <dcat:dataset rdf:resource="{iso19139:ResourceUri(iso19139:getResourceCode(.))}"/>
    <dcat:record rdf:resource="{iso19139:RecordUri(gmd:fileIdentifier/gco:CharacterString)}"/>
  </xsl:template>


  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"
                mode="to-dcat">
    <!-- Catalogue records
      "A record in a data catalog, describing a single dataset."

      xpath: //gmd:MD_Metadata|//*[@gco:isoType='gmd:MD_Metadata']
    -->
    <dcat:CatalogRecord rdf:about="{iso19139:RecordUri(gmd:fileIdentifier/gco:CharacterString)}">
      <!-- Link to a dcat:Dataset or a rdf:Description for services and feature catalogue. -->
      <foaf:primaryTopic rdf:resource="{iso19139:ResourceUri(iso19139:getResourceCode(.))}"/>
      <dct:conformsTo rdf:resource="https://www.iso.org/standard/32557.html"/>
      <!-- Metadata change date.
      "The date is encoded as a literal in "YYYY-MM-DD" form (ISO 8601 Date and Time Formats)." -->
      <xsl:variable name="date" select="substring-before(gmd:dateStamp/gco:DateTime, 'T')"/>
      <dct:issued>
        <xsl:value-of select="$date"/>
      </dct:issued>
      <dct:modified>
        <xsl:value-of select="$date"/>
      </dct:modified>
      <xsl:call-template name="add-reference">
        <xsl:with-param name="uuid" select="gmd:fileIdentifier/gco:CharacterString"/>
      </xsl:call-template>
    </dcat:CatalogRecord>

    <xsl:apply-templates select="gmd:identificationInfo/*"
                         mode="to-dcat"/>
  </xsl:template>


  <!-- Add references for HTML and XML metadata record link -->
  <xsl:template name="add-reference">
    <xsl:param name="uuid"/>

    <dct:references>
      <rdf:Description rdf:about="{$url}/srv/api/records/{$uuid}/formatters/xml">
        <dct:format>
          <dct:IMT>
            <rdf:value>application/xml</rdf:value>
            <rdfs:label>XML</rdfs:label>
          </dct:IMT>
        </dct:format>
      </rdf:Description>
    </dct:references>

    <dct:references>
      <!-- SIB addon-->
      <!-- <rdf:Description rdf:about="{$url}/srv/api/records/{$uuid}"> -->
      <rdf:Description rdf:about="{$url}/srv/fre/catalog.search#/metadata/{$uuid}">
        <dct:format>
          <dct:IMT>
            <rdf:value>text/html</rdf:value>
            <rdfs:label>HTML</rdfs:label>
          </dct:IMT>
        </dct:format>
      </rdf:Description>
    </dct:references>
  </xsl:template>

  <!-- Create all references for ISO19139 record (if rdf.metadata.get) or records (if rdf.search) -->
  <xsl:template match="gmd:MD_Metadata|*[@gco:isoType='gmd:MD_Metadata']"
                mode="references">

    <xsl:variable name="uuid" select="gmd:fileIdentifier/gco:CharacterString"/>

    <!-- Keywords -->
    <xsl:for-each-group select="//gmd:MD_Keywords[(gmd:thesaurusName)]/gmd:keyword"
                        group-by="gco:CharacterString|gmx:Anchor">
      <skos:Concept
        rdf:about="{iso19139:getKeywordURI(., iso19139:getThesaurusURI(../gmd:thesaurusName, $resourcePrefix))}">
        <skos:inScheme
          rdf:resource="{iso19139:getThesaurusURI(../gmd:thesaurusName, $resourcePrefix)}"/>
        <skos:prefLabel>
          <xsl:value-of select="(gco:CharacterString|gmx:Anchor)"/>
        </skos:prefLabel>
      </skos:Concept>
    </xsl:for-each-group>


    <!-- Distribution
      "Represents a specific available form of a dataset. Each dataset might be available in different
      forms, these forms might represent different formats of the dataset, different endpoints,...
      Examples of Distribution include a downloadable CSV file, an XLS file representing the dataset,
      an RSS feed ..."

      Download, WebService, Feed

      xpath: //gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource
    -->
    <xsl:for-each-group
      select="//gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource"
      group-by="gmd:linkage/gmd:URL">
      <dcat:Distribution rdf:about="{iso19139:RecordUri($uuid)}#{encode-for-uri(gmd:protocol/*/text())}-{encode-for-uri(gmd:name/(gco:CharacterString|gmx:Anchor)/text())}">
        <!--
          "points to the location of a distribution. This can be a direct download link, a link
          to an HTML page containing a link to the actual data, Feed, Web Service etc.
          the semantic is determined by its domain (Distribution, Feed, WebService, Download)."
        -->
        <dcat:accessURL>
          <xsl:value-of select="gmd:linkage/gmd:URL"/>
        </dcat:accessURL>
        <!-- xpath: gmd:linkage/gmd:URL -->

        <xsl:if test="gmd:name/(gco:CharacterString|gmx:Anchor) != ''">
          <dct:title>
            <xsl:value-of select="gmd:name/(gco:CharacterString|gmx:Anchor)"/>
          </dct:title>
        </xsl:if>
        <!-- xpath: gmd:name/gco:CharacterString -->

        <!-- "The size of a distribution.":N/A
          <dcat:size></dcat:size>
        -->

          <xsl:if test="(gmd:protocol/gmx:Anchor/@xlink:href)[1]!=''">
          <dcat:mediaType>
            <xsl:attribute name="rdf:resource" select="(gmd:protocol/gmx:Anchor/@xlink:href)[1]"/>
            <xsl:value-of select="(gmd:protocol/gmx:Anchor)[1]"/>
          </dcat:mediaType>
          </xsl:if>

          <!-- SIB addon-->
          <xsl:if test="(gmd:description/gco:CharacterString)[1]!=''">
          <dct:description>
            <xsl:value-of select="(gmd:description/gco:CharacterString)[1]"/>
          </dct:description>
          </xsl:if>

          <xsl:if test="(gmd:protocol/gco:CharacterString)[1]!=''">
          <dct:format>
            <xsl:value-of select="(gmd:protocol/gco:CharacterString)[1]"/>
          </dct:format>
          </xsl:if>

      </dcat:Distribution>
    </xsl:for-each-group>


    <xsl:for-each-group
      select="//gmd:CI_ResponsibleParty[gmd:organisationName/gco:CharacterString!='']"
      group-by="gmd:organisationName/gco:CharacterString">
      <!-- Organization description.
        Organization could be linked to a catalogue, a catalogue record.

        xpath: //gmd:organisationName
      -->
      <foaf:Organization rdf:about="{$resourcePrefix}/organizations/{encode-for-uri(current-grouping-key())}">
        <foaf:name>
          <xsl:value-of select="current-grouping-key()"/>
        </foaf:name>
        <!-- xpath: gmd:organisationName/gco:CharacterString -->
        <xsl:for-each-group
          select="//gmd:CI_ResponsibleParty[gmd:organisationName/gco:CharacterString=current-grouping-key()]"
          group-by="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
          <foaf:member
            rdf:resource="{$resourcePrefix}/persons/{encode-for-uri(iso19139:getContactId(.))}"/>
        </xsl:for-each-group>
      </foaf:Organization>
    </xsl:for-each-group>

    <xsl:for-each-group select="//gmd:CI_ResponsibleParty"
                        group-by="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
      <!-- Organization member

        xpath: //gmd:CI_ResponsibleParty-->

      <foaf:Agent rdf:about="{$resourcePrefix}/persons/{encode-for-uri(iso19139:getContactId(.))}">
        <xsl:if test="gmd:individualName/gco:CharacterString">
          <foaf:name>
            <xsl:value-of select="gmd:individualName/gco:CharacterString"/>
          </foaf:name>
        </xsl:if>
        <!-- xpath: gmd:individualName/gco:CharacterString -->
        <xsl:if
          test="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString">
          <foaf:phone>
            <xsl:value-of
              select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString"/>
          </foaf:phone>
        </xsl:if>
        <!-- xpath: gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString -->
        <xsl:if
          test="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
          <foaf:mbox
            rdf:resource="mailto:{gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString}"/>
        </xsl:if>
        <!-- xpath: gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString -->
      </foaf:Agent>
    </xsl:for-each-group>
  </xsl:template>


  <!-- Service
    Create a simple rdf:Description. To be improved.

    xpath: //srv:SV_ServiceIdentification||//*[contains(@gco:isoType, 'SV_ServiceIdentification')]
  -->
  <xsl:template
    match="srv:SV_ServiceIdentification|*[contains(@gco:isoType, 'SV_ServiceIdentification')]"
    mode="to-dcat">
    <rdf:Description rdf:about="{$resourcePrefix}/{iso19139:getResourceCode(../../.)}">
      <xsl:call-template name="to-dcat"/>
    </rdf:Description>
  </xsl:template>


  <!-- Dataset
    "A collection of data, published or curated by a single source, and available for access or
    download in one or more formats."

    xpath: //gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]
  -->
  <xsl:template match="gmd:MD_DataIdentification|*[contains(@gco:isoType, 'MD_DataIdentification')]"
                mode="to-dcat">

    <!-- SIB addon-->
    <!-- <dcat:Dataset rdf:about="{$resourcePrefix}/datasets/{iso19139:getResourceCode(../../.)}"> -->
    <xsl:variable name="uuid" select="../../gmd:fileIdentifier/gco:CharacterString"/>
    <dcat:Dataset rdf:about="{$url}/srv/fre/catalog.search#/metadata/{$uuid}">
      <xsl:call-template name="to-dcat"/>
    </dcat:Dataset>
  </xsl:template>


  <!-- Build a dcat record for a dataset or service -->
  <xsl:template name="to-dcat">

    <xsl:variable name="uuid" select="../../gmd:fileIdentifier/gco:CharacterString"/>

    <!-- "A unique identifier of the dataset." -->
    <dct:identifier>
      <xsl:value-of select="iso19139:getResourceCode(../../.)"/>
    </dct:identifier>
    <!-- xpath: gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code -->

    <!-- SIB addon-->
    <dcat:landingPage>
      <xsl:value-of select="$url"/>/srv/fre/catalog.search#/metadata/<xsl:value-of select="$uuid"/>
    </dcat:landingPage>

    <dct:title>
      <xsl:value-of select="gmd:citation/*/gmd:title/gco:CharacterString"/>
    </dct:title>
    <!-- xpath: gmd:identificationInfo/*/gmd:citation/*/gmd:title/gco:CharacterString -->


    <dct:abstract>
      <xsl:value-of select="gmd:abstract/gco:CharacterString"/>

      <!-- SIB addon-->
      <!-- Layout will be visible only in source mode in the browser. If not in source mode, newlines won't be displayed and the keywords will be shown inline -->
      <xsl:text>&#xa;</xsl:text> <!-- linebreak -->
      <!-- Keywords -->
      <xsl:for-each-group select="//gmd:MD_Keywords[(gmd:thesaurusName)]/gmd:keyword"
      group-by="gco:CharacterString|gmx:Anchor">
        <xsl:text>&#xa;</xsl:text> <!-- linebreak -->
        <xsl:value-of select="normalize-space(../gmd:thesaurusName/*/gmd:title)"/> : <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/><xsl:text>.</xsl:text>
      </xsl:for-each-group>
    </dct:abstract>
    <!-- xpath: gmd:identificationInfo/*/gmd:abstract/gco:CharacterString -->


    <!-- "A keyword or tag describing the dataset."
      Create dcat:keyword if no thesaurus name information available.
    -->
    <xsl:for-each
      select="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString">
      <dcat:keyword>
        <xsl:value-of select="."/>
      </dcat:keyword>
    </xsl:for-each>
    <xsl:for-each
      select="gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword/gmx:Anchor">
      <dcat:keyword rdf:resource="{@xlink:href}">
        <xsl:value-of select="."/>
      </dcat:keyword>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords[not(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString -->


    <!-- "The main category of the dataset. A dataset can have multiple themes."
    -->

    <!-- SIB addon-->
    <!-- If keyword is added using Anchor mode, this should be reflected here and the theme should point to the anchor link
    Used for HVD classification: use Anchor. The theme should then be discoverable by data.gouv.fr directly
     -->
    <xsl:for-each
      select="gmd:descriptiveKeywords/gmd:MD_Keywords[(gmd:thesaurusName)]/gmd:keyword/gco:CharacterString">
      <dcat:theme
        rdf:resource="{iso19139:getKeywordURI(.., iso19139:getThesaurusURI(../../gmd:thesaurusName, $resourcePrefix))}"/>
    </xsl:for-each>
    <xsl:for-each
      select="gmd:descriptiveKeywords/gmd:MD_Keywords[(gmd:thesaurusName)]/gmd:keyword/gmx:Anchor">
      <dcat:theme rdf:resource="{@xlink:href}" />
    </xsl:for-each>

    <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode[.!='']">
      <!-- FIXME Is there any public URI pointing to topicCategory enumeration ? -->
      <dcat:theme rdf:resource="https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/{translate(.,' ','')}"/>
    </xsl:for-each>

    <!-- Thumbnail -->
    <xsl:for-each
      select="gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString[normalize-space(.)!='']">
      <foaf:thumbnail rdf:resource="{replace(., ' ', '%20')}" />
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:graphicOverview/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString -->

    <!-- "Spatial coverage of the dataset." -->
    <xsl:for-each select="gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox">
      <xsl:variable name="coords" select="
        concat(gmd:westBoundLongitude/gco:Decimal, ' ', gmd:southBoundLatitude/gco:Decimal),
        concat(gmd:westBoundLongitude/gco:Decimal, ' ', gmd:northBoundLatitude/gco:Decimal),
        concat(gmd:eastBoundLongitude/gco:Decimal, ' ', gmd:northBoundLatitude/gco:Decimal),
        concat(gmd:eastBoundLongitude/gco:Decimal, ' ', gmd:southBoundLatitude/gco:Decimal),
        concat(gmd:westBoundLongitude/gco:Decimal, ' ', gmd:southBoundLatitude/gco:Decimal)
        ">
      </xsl:variable>
      <dct:spatial>
        <ogc:Polygon>
          <geo:asWKT rdf:datatype="http://www.opengis.net/rdf#wktLiteral">
            Polygon((<xsl:value-of select="string-join($coords, ', ')"/>))
          </geo:asWKT>
        </ogc:Polygon>
      </dct:spatial>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox -->


    <!-- "The temporal period that the dataset covers." -->
    <!-- TODO could be improved-->
    <xsl:for-each
      select="gmd:extent/*/gmd:temporalElement/gmd:EX_TemporalExtent/gmd:extent/(gml:TimePeriod|gml320:TimePeriod)">
      <dct:temporal>
        <xsl:value-of select="gml:beginPosition|gml320:beginPosition"/>
        <xsl:if test="gml:endPosition|gml320:endPosition">
          /
          <xsl:value-of select="gml:endPosition|gml320:endPosition"/>
        </xsl:if>
      </dct:temporal>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:extent/*/gmd:temporalElement -->

    <xsl:for-each
      select="gmd:citation/*/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='creation']">
      <dct:issued>
        <xsl:value-of select="gmd:date/gco:Date|gmd:date/gco:DateTime"/>
      </dct:issued>
    </xsl:for-each>
    <xsl:for-each
      select="gmd:citation/*/gmd:date/gmd:CI_Date[gmd:dateType/gmd:CI_DateTypeCode/@codeListValue='revision']">
      <dct:updated>
        <xsl:value-of select="gmd:date/gco:Date|gmd:date/gco:DateTime"/>
      </dct:updated>
    </xsl:for-each>

    <!-- "An entity responsible for making the dataset available" -->
    <xsl:for-each select="gmd:pointOfContact/*/gmd:organisationName/gco:CharacterString[.!='']">
      <dct:publisher rdf:resource="{$resourcePrefix}/organizations/{encode-for-uri(.)}"/>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:pointOfContact -->

    <!-- "The frequency with which dataset is published." See placetime.com intervals. -->
    <!-- SIB addon-->

    <!--
    RDF Property:	dcterms:accrualPeriodicity
    Definition:	The frequency at which a dataset is published.
    Range:	dcterms:Frequency (A rate at which something recurs)
    Usage note:	The value of dcterms:accrualPeriodicity gives the rate at which the dataset-as-a-whole is updated. This may be complemented by dcat:temporalResolution to give the time between collected data points in a time series.
    -->
    <xsl:variable name="isoFrequencyToDublinCore"
                  as="node()*">
      <entry key="continual">CONT</entry>
      <entry key="daily">DAILY</entry>
      <entry key="weekly">WEEKLY</entry>
      <entry key="fortnightly">BIWEEKLY</entry>
      <entry key="monthly">MONTHLY</entry>
      <entry key="quarterly">QUARTERLY</entry>
      <entry key="biannually">ANNUAL_2</entry>
      <entry key="annually">ANNUAL</entry>
      <entry key="irregular">IRREG</entry>
      <entry key="unknown">UNKNOWN</entry>
      <entry key="notPlanned">PUNCTUAL</entry>
      <entry key="asNeeded">PUNCTUAL</entry>
      <!--
      <entry key="asNeeded"></entry>
      <entry key="notPlanned"></entry>
      -->
    </xsl:variable>

    <!-- Try mapping the values to Dublin Core values if listed (see above). Deals with the fact that codelists are slightly diverging between DC and ISO -->
    <xsl:for-each
      select="gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
       <xsl:variable name="dcFrequency"
                  as="xs:string?"
                  select="$isoFrequencyToDublinCore[@key = current()/*/@codeListValue]"/>
      <dct:accrualPeriodicity>
        <!-- <xsl:value-of select="@codeListValue"/> -->
        <!-- <xsl:value-of select="$dcFrequency"/> -->
        <xsl:value-of select="if($dcFrequency)
                                 then $dcFrequency
                                 else */@codeListValue"/>
        <!-- <dct:Frequency rdf:about="{$dcFrequency}"/> -->
      </dct:accrualPeriodicity>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode/@codeListValue -->

    <!-- "This is usually geographical or temporal but can also be other dimension" ??? -->
    <xsl:for-each
      select="gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[.!='']">
      <dcat:granularity>
        <xsl:value-of select="."/>
      </dcat:granularity>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer -->


    <!--
      "The language of the dataset."
      "This overrides the value of the catalog language in case of conflict"
    -->
    <xsl:for-each select="gmd:language/gmd:LanguageCode/@codeListValue">
      <dct:language>
        <xsl:value-of select="."/>
      </dct:language>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:language/gmd:LanguageCode/@codeListValue -->


    <!-- dct:license content -->
    <!-- "The license under which the dataset is published and can be reused." -->
    <xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:useConstraints">
      <xsl:choose>
        <xsl:when test="gmd:MD_RestrictionCode[@codeListValue!='otherRestrictions']">
          <dct:license>
            <xsl:value-of select="@codeListValue"/>
          </dct:license>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="legalOtherConstraints">
              <xsl:with-param name="ocnode"><xsl:copy-of select="./following-sibling::gmd:otherConstraints[1]"/></xsl:with-param>
              <xsl:with-param name="tagname">license</xsl:with-param>
            </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <!--  Access constraints should not be stored under license, but rather on accessRights category,
          cf https://semiceu.github.io/GeoDCAT-AP/releases/2.0.0/#conditions-for-access-and-use-and-limitations-on-public-access-use-limitation-and-access-other-constraints 
    -->
    <xsl:for-each select="gmd:resourceConstraints/gmd:MD_LegalConstraints/gmd:accessConstraints">
      <xsl:choose>
        <xsl:when test="gmd:MD_RestrictionCode[@codeListValue!='otherRestrictions']">
          <dct:accessRights>
            <xsl:value-of select="@codeListValue"/>
          </dct:accessRights>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="legalOtherConstraints">
              <xsl:with-param name="ocnode"><xsl:copy-of select="./following-sibling::gmd:otherConstraints[1]"/></xsl:with-param>
              <xsl:with-param name="tagname">accessRights</xsl:with-param>
            </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <!-- xpath: gmd:identificationInfo/*/gmd:resourceConstraints/??? -->

    <xsl:for-each select="../../gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine">
      <dcat:distribution rdf:resource="{iso19139:RecordUri($uuid)}#{encode-for-uri(gmd:CI_OnlineResource/gmd:protocol/*/text())}-{encode-for-uri(gmd:CI_OnlineResource/gmd:name/(gco:CharacterString|gmx:Anchor)/text())}"/>
    </xsl:for-each>

    <!-- xpath: gmd:distributionInfo/*/gmd:transferOptions/*/gmd:onLine/gmd:CI_OnlineResource -->



    <!-- SIB addon-->
    <!-- Add contactPoint vcard, for data.gouv harvesting. Use the metadata point of -->
    <xsl:for-each-group
      select="gmd:pointOfContact/gmd:CI_ResponsibleParty[gmd:organisationName/gco:CharacterString!='']"
      group-by="gmd:organisationName/gco:CharacterString">
      <!-- Organization description.
        Organization could be linked to a catalogue, a catalogue record.

        xpath: //gmd:organisationName
      -->
      <dcat:contactPoint>
        <vcard:Kind rdf:about="{$resourcePrefix}/organizations/{encode-for-uri(current-grouping-key())}">
          <vcard:fn><xsl:value-of select="current-grouping-key()"/></vcard:fn>
          <xsl:for-each-group
            select="//gmd:CI_ResponsibleParty[gmd:organisationName/gco:CharacterString=current-grouping-key()]"
            group-by="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString">
            <vcard:hasEmail
              rdf:resource="mailto:{current-grouping-key()}"/>
          </xsl:for-each-group>
        </vcard:Kind>
      </dcat:contactPoint>
    </xsl:for-each-group>

    <!-- ISO19110 relation
      "This usually consisits of a table providing explanation of columns meaning, values interpretation and acronyms/codes used in the data."
    -->
    <xsl:for-each
      select="../../gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation/@uuidref">
      <dcat:dataDictionary rdf:resource="{iso19139:RecordUri(.)}"/>
    </xsl:for-each>
    <!-- xpath: gmd:contentInfo/gmd:MD_FeatureCatalogueDescription/gmd:featureCatalogueCitation/@uuidref -->

    <!-- Dataset relation
    -->
    <xsl:for-each select="srv:operatesOn/@uuidref ">
      <dct:relation rdf:resource="{iso19139:RecordUri(.)}"/>
    </xsl:for-each>


    <xsl:for-each select="gmd:aggregationInfo/gmd:MD_AggregateInformation">
      <dct:relation
        rdf:resource="{iso19139:RecordUri(gmd:aggregateDataSetIdentifier/gmd:MD_Identifier/gmd:code/gco:CharacterString)}"/>
    </xsl:for-each>

    <!-- Source relation -->
    <xsl:for-each select="/root/gui/relation/sources/response/metadata">
      <dct:relation rdf:resource="{iso19139:RecordUri(geonet:info/uuid)}"/>
    </xsl:for-each>


    <!-- Parent/child relation -->
    <xsl:for-each select="../../gmd:parentIdentifier/gco:CharacterString[.!='']">
      <dct:relation rdf:resource="{iso19139:RecordUri(.)}"/>
    </xsl:for-each>
    <xsl:for-each select="/root/gui/relation/children/response/metadata">
      <dct:relation rdf:resource="{iso19139:RecordUri(geonet:info/uuid)}"/>
    </xsl:for-each>

    <!-- Service relation -->
    <xsl:for-each select="/root/gui/relations/services/response/metadata">
      <dct:relation rdf:resource="{iso19139:RecordUri(geonet:info/uuid)}"/>
    </xsl:for-each>


    <!--
      "A related document such as technical documentation, agency program page, citation, etc."

      TODO : only for URL ?
      <xsl:for-each select="gmd:citation/*/gmd:otherCitationDetails/gco:CharacterString">
      <dct:reference rdf:resource="url?"/>
      </xsl:for-each>
    -->
    <!-- xpath: gmd:identificationInfo/*/gmd:citation/*/gmd:otherCitationDetails/gco:CharacterString -->


    <!-- "describes the quality of data." -->
    <xsl:for-each
      select="../../gmd:dataQualityInfo/*/gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString">
      <dcat:dataQuality>
        <!-- rdfs:literal -->
        <xsl:value-of select="."/>
      </dcat:dataQuality>
    </xsl:for-each>
    <!-- xpath: gmd:dataQualityInfo/*/gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString -->


    <!-- FIXME ?
      <void:dataDump></void:dataDump>-->
  </xsl:template>


  <!--
    Process the otherContraints in LegalResources differently depending on the previous sibling. If gmd:useConstraints use dct:license, if gmd:accessConstraints use dct:accessRights
  -->
  <xsl:template name="legalOtherConstraints">
    <xsl:param name="ocnode"/>
    <xsl:param name="tagname"/>

    <xsl:choose>
      <xsl:when test="$ocnode/gmd:otherConstraints/gmx:Anchor">
        <xsl:element name="dct:{$tagname}">
          <xsl:attribute name="rdf:resource">
              <xsl:value-of select="$ocnode/gmd:otherConstraints/gmx:Anchor/@xlink:href"/>
          </xsl:attribute>
          <xsl:value-of select="$ocnode/gmd:otherConstraints/gmx:Anchor"/>
        </xsl:element>
      </xsl:when>
      <xsl:when test="$ocnode/gmd:otherConstraints/gco:CharacterString">
        <xsl:element name="dct:{$tagname}">
          <xsl:value-of select="$ocnode/gmd:otherConstraints/gco:CharacterString"/>
        </xsl:element>
      </xsl:when>
      <!--      <xsl:otherwise>-->
      <!--          <xsl:copy-of select="$ocnode"/>-->
      <!--      </xsl:otherwise>-->
    </xsl:choose>
  </xsl:template>


  <!--
    Get resource (dataset or service) identifier if set and return metadata UUID if not.
  -->
  <xsl:function name="iso19139:getResourceCode" as="xs:string">
    <xsl:param name="metadata" as="node()"/>

    <xsl:value-of select="if ($metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString!='')
      then $metadata/gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString
      else $metadata/gmd:fileIdentifier/gco:CharacterString"/>
  </xsl:function>


  <!--
    Get thesaurus identifier, otherCitationDetails value, citation @id or thesaurus title.
  -->
  <xsl:function name="iso19139:getThesaurusURI" as="xs:string">
    <xsl:param name="thesaurusName" as="node()"/>
    <xsl:param name="resourcePrefix" as="xs:string"/>

    <xsl:variable name="prefixIfNoHttp"
                  select="concat($resourcePrefix, '/registries/vocabularies/')"/>

    <xsl:variable name="thesaurusUri"
                  select="if ($thesaurusName/*/gmd:title/gmx:Anchor/@xlink:href)
                          then $thesaurusName/*/gmd:title/gmx:Anchor/@xlink:href
                          else if ($thesaurusName/*/gmd:otherCitationDetails/*[. != ''])
                          then $thesaurusName/*/gmd:otherCitationDetails/*[. != '']
                          else if ($thesaurusName/gmd:CI_Citation/@id[. != ''])
                          then $thesaurusName/gmd:CI_Citation/@id[. != '']
                          else if ($thesaurusName/*/gmd:title/gmx:Anchor)
                          then $thesaurusName/*/gmd:title/gmx:Anchor
                          else if ($thesaurusName/*/gmd:title/gco:CharacterString)
                          then $thesaurusName/*/gmd:title/gco:CharacterString
                          else generate-id($thesaurusName)"/>

    <xsl:value-of select="if (starts-with($thesaurusUri, 'http'))
                          then $thesaurusUri
                          else concat($prefixIfNoHttp,
                                encode-for-uri($thesaurusUri))"/>
  </xsl:function>

  <xsl:function name="iso19139:getKeywordURI" as="xs:string">
    <xsl:param name="keyword" as="node()"/>
    <xsl:param name="thesaurusUri" as="xs:string"/>

    <xsl:variable name="keywordUri"
                  select="if ($keyword/gmx:Anchor/@xlink:href)
                          then $keyword/gmx:Anchor/@xlink:href
                          else if ($keyword/gco:CharacterString)
                          then $keyword/gco:CharacterString
                          else generate-id($keyword)"/>

    <xsl:value-of select="if (starts-with($keywordUri, 'http'))
                          then $keywordUri
                          else concat($thesaurusUri, '/concepts/',
                                encode-for-uri($keywordUri))"/>
  </xsl:function>

  <!--
    Get contact identifier (for the time being = email and node generated identifier if no email available)
  -->
  <xsl:function name="iso19139:getContactId" as="xs:string">
    <xsl:param name="responsibleParty" as="node()"/>

    <xsl:variable name="email"
                  select="$responsibleParty/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/gco:CharacterString[. != '']"/>
    <xsl:value-of select="if ($email != '') then $email
                          else generate-id($responsibleParty)"/>
  </xsl:function>


  <xsl:function name="iso19139:RecordUri">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:value-of select="concat($url,'/records/',encode-for-uri($id))"/>
  </xsl:function>
  <xsl:function name="iso19139:ResourceUri">
    <xsl:param name="id" as="xs:string?"/>
    <xsl:value-of select="concat($resourcePrefix,'/',encode-for-uri($id))"/>
  </xsl:function>

</xsl:stylesheet>
