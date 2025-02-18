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

<!--
  The main entry point for all user interface generated
  from XSLT.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                exclude-result-prefixes="#all">

  <xsl:output omit-xml-declaration="yes" method="html" doctype-system="html" indent="yes"
              encoding="UTF-8"/>

  <xsl:include href="common/base-variables.xsl"/>
  <xsl:include href="base-layout-cssjs-loader.xsl"/>
  <xsl:include href="skin/default/skin.xsl"/>

  <xsl:template match="/">
    <html ng-app="{$angularModule}" lang="{$lang2chars}" id="ng-app">
      <head>
        <title>
            <xsl:value-of select="util:getNodeName('', $lang, true())"/>
        </title>
        <meta charset="utf-8"/>
        <meta name="viewport" content="initial-scale=1.0"/>
        <meta name="apple-mobile-web-app-capable" content="yes"/>

        <meta name="description" content=""/>
        <meta name="keywords" content=""/>


        <link rel="icon" sizes="16x16 32x32 48x48" type="image/png"
              href="../../images/logos/favicon.png"/>
        <link href="rss.search?sortBy=changeDate" rel="alternate" type="application/rss+xml"
              title="{concat($env/system/site/name, ' - ', $env/system/site/organization)}"/>
        <link href="portal.opensearch" rel="search" type="application/opensearchdescription+xml"
              title="{concat($env/system/site/name, ' - ', $env/system/site/organization)}"/>

        <xsl:call-template name="css-load"/>
      </head>


      <!-- The GnCatController takes care of
      loading site information, check user login state
      and a facet search to get main site information.
      -->
      <body data-ng-controller="GnCatController" data-ng-class="[isHeaderFixed ? 'gn-header-fixed' : 'gn-header-relative', isLogoInHeader ? 'gn-logo-in-header' : 'gn-logo-in-navbar', isFooterEnabled ? 'gn-show-footer' : 'gn-hide-footer']">

        <div data-gn-alert-manager=""></div>

        <xsl:choose>
          <xsl:when test="ends-with($service, 'nojs')">
            <!-- No JS degraded mode ... -->
            <div>
              <!-- TODO: Add header/footer -->
              <xsl:apply-templates mode="content" select="."/>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="$isJsEnabled">
              <xsl:call-template name="no-js-alert"/>
            </xsl:if>
            <!-- AngularJS application -->
            <xsl:if test="$angularApp != 'gn_search' and $angularApp != 'gn_viewer' and $angularApp != 'gn_formatter_viewer'">
              <div class="navbar navbar-default gn-top-bar"
                   role="navigation"
                   data-ng-hide="layout.hideTopToolBar"
                   data-ng-include="isMenubarAccessible ? '{$uiResourcesPath}templates/top-toolbar-accessible.html' : '{$uiResourcesPath}templates/top-toolbar.html'"></div>
            </xsl:if>


            <div data-gn-alert-manager=""></div>
            <xsl:if test="$angularApp = 'gn_search' or $angularApp = 'gn_viewer' or $angularApp = 'gn_formatter_viewer'">
            <style>

              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:100;
              src:url(/static/fonts/Marianne-Thin.otf) format("opentype");
              }
              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:300;
              src:url(/static/fonts/Marianne-Light.otf) format("opentype");
              }
              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:400;
              src:url(/static/fonts/Marianne-Regular.otf) format("opentype");
              }
              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:500;
              src:url(/static/fonts/Marianne-Medium.otf) format("opentype");
              }
              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:700;
              src:url(/static/fonts/Marianne-Bold.otf) format("opentype");
              }
              @font-face{
              font-family:"Marianne";
              font-style:normal;
              font-weight:900;
              src:url(/static/fonts/Marianne-ExtraBold.otf) format("opentype");
              }
              @font-face{
              font-family:'Font Awesome 5 Free';
              font-style:normal;
              font-weight:900;
              font-display:block;
              src:url(/static/fonts/fa-solid-900.eot);
              src:url(/static/fonts/fa-solid-900.eot?#iefix) format("embedded-opentype"),url(/static/fonts/fa-solid-900.woff2) format("woff2"),url(/static/fonts/fa-solid-900.woff) format("woff"),url(/static/fonts/fa-solid-900.ttf) format("truetype"),url(/images/fa-solid-900.svg#fontawesome) format("svg");
              }
              @font-face{
              font-family:'Font Awesome 5 Brands';
              font-style:normal;
              font-weight:400;
              font-display:block;
              src:url(/static/fonts/fa-brands-400.eot);
              src:url(/static/fonts/fa-brands-400.eot?#iefix) format("embedded-opentype"),url(/static/fonts/fa-brands-400.woff2) format("woff2"),url(/static/fonts/fa-brands-400.woff) format("woff"),url(/static/fonts/fa-brands-400.ttf) format("truetype"),url(/images/fa-brands-400.svg#fontawesome) format("svg");
              }

              .gn-full {
                min-height: calc(100vh - 260px);
                top:120px;
              }
              /* Main container in admin pages */
              sib-header + div,
              .navbar.gn-top-bar + .container-fluid {
                min-height: calc(100vh - 320px);
              }
            </style>
            <sib-header src="SET_NATUREFRANCE_MENU_URL_HERE"></sib-header>
            </xsl:if>


            <xsl:apply-templates mode="content" select="."/>

            <xsl:if test="$angularApp = 'gn_search' or $angularApp = 'gn_viewer' or $angularApp = 'gn_formatter_viewer'">
              <sib-footer src="SET_NATUREFRANCE_MENU_URL_HERE"></sib-footer>
            </xsl:if>

            <xsl:if test="$isJsEnabled">
              <xsl:call-template name="javascript-load"/>
            </xsl:if>

          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="no-js-alert">
    <noscript>
      <xsl:call-template name="header"/>
      <div class="container page">
        <div class="row gn-row-main">
          <div class="col-sm-8 col-sm-offset-2">
            <h1><xsl:value-of select="$env/system/site/name"/></h1>
            <p><xsl:value-of select="/root/gui/strings/mainpage2"/></p>
            <p><xsl:value-of select="/root/gui/strings/mainpage1"/></p>
            <br/><br/>
            <div class="alert alert-warning" data-ng-hide="">
              <strong>
                <xsl:value-of select="$i18n/warning"/>
              </strong>
              <xsl:text> </xsl:text>
              <xsl:copy-of select="$i18n/nojs"/>
            </div>
          </div>
        </div>
      </div>
      <xsl:call-template name="footer"/>
    </noscript>
  </xsl:template>

</xsl:stylesheet>
