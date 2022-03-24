#!/bin/bash
set -e

# Apply custom config if not already done
if [[ -f "/custom-conf/applied" ]]; then
  echo "SIB custom configuration already set"

else
  echo "Applying SIB custom configuration"

  # Copy security configuration
  cp /custom-conf/config-security/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/

  if [[ "$ENABLE_CAS" == "yes" ]]; then
    echo "Enabling CAS: $ENABLE_CAS"
    # Fix the login button in the top toolbar
    cp /custom-conf/html/top-toolbar-accessible.html ${JETTY_BASE}/webapps/geonetwork/catalog/templates/

    # Enable CAS
    sed -i 's|<!--<import resource="config-security-cas.xml"/>-->|<import resource="config-security-cas.xml"/>|' ${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.xml
    sed -i 's|<!-- <import resource="config-security-cas-database.xml"/> -->|<import resource="config-security-cas-database.xml"/>|' ${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.xml

    # Configure CAS
    sed -i "s|cas.baseURL=.*|cas.baseURL=${CAS_BASE_URL}|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
    sed -i "s|cas.ticket.validator.url=.*|cas.ticket.validator.url=${CAS_BASE_URL}|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
    sed -i "s|cas.login.url=.*|cas.login.url=${CAS_BASE_URL}/login|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
    sed -i "s|cas.logout.url=.*|cas.logout.url=${CAS_BASE_URL}/logout?service=\${geonetwork.https.url}/|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
    sed -i "s|geonetwork.https.url=.*|geonetwork.https.url=${GEONETWORK_URL}|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"

    # Configure the signin page to use casLogin param (could also be done using admin GUI->create new UI)
    ui_configuration='{"langDetector":{"fromHtmlTag":false,"regexp":"^(?:/.+)?/.+/([a-z]{2,3})/.+","default":"eng"},"nodeDetector":{"regexp":"^(?:/.+)?/(.+)/[a-z]{2,3}/.+","default":"srv"},"serviceDetector":{"regexp":"^(?:/.+)?/.+/[a-z]{2,3}/(.+)","default":"catalog.search"},"baseURLDetector":{"regexp":"^((?:/.+)?)+/.+/[a-z]{2,3}/.+","default":"/geonetwork"},"mods":{"global":{"humanizeDates":true,"dateFormat":"DD-MM-YYYY HH:mm","timezone":"Browser"},"footer":{"enabled":true,"showSocialBarInFooter":true},"header":{"enabled":true,"languages":{"eng":"en","fre":"fr"},"isLogoInHeader":false,"logoInHeaderPosition":"left","fluidHeaderLayout":true,"showGNName":true,"isHeaderFixed":false,"isMenubarAccessible":true},"cookieWarning":{"enabled":true,"cookieWarningMoreInfoLink":"","cookieWarningRejectLink":""},"home":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.search#/home","showSocialBarInFooter":true,"fluidLayout":true,"facetConfig":{"inspireThemeUri":{"terms":{"field":"inspireThemeUri","size":34}},"cl_topic.key":{"terms":{"field":"cl_topic.key","size":20}},"cl_hierarchyLevel.key":{"terms":{"field":"cl_hierarchyLevel.key","size":10}}}},"search":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.search#/search","hitsperpageValues":[30,60,120],"paginationInfo":{"hitsPerPage":30},"queryBase":"any:(${any}) resourceTitleObject.default:(${any})^2","queryTitle":"${any}","searchOptions":true,"scoreConfig":{"boost":"5","functions":[{"filter":{"exists":{"field":"parentUuid"}},"weight":0.3},{"filter":{"match":{"cl_status.key":"obsolete"}},"weight":0.3},{"gauss":{"dateStamp":{"scale":"365d","offset":"90d","decay":0.5}}}],"score_mode":"multiply"},"autocompleteConfig":{"query":{"bool":{"must":[{"multi_match":{"query":"","type":"bool_prefix","fields":["resourceTitleObject.*","resourceAbstractObject.*","tag","resourceIdentifier"]}}]}},"_source":["resourceTitleObject"],"from":0,"size":20},"moreLikeThisConfig":{"more_like_this":{"fields":["resourceTitleObject.default","resourceAbstractObject.default","tag.raw"],"like":null,"min_term_freq":1,"max_query_terms":12}},"facetTabField":"","isVegaEnabled":true,"facetConfig":{"cl_hierarchyLevel.key":{"terms":{"field":"cl_hierarchyLevel.key"},"aggs":{"format":{"terms":{"field":"format"}}}},"cl_spatialRepresentationType.key":{"terms":{"field":"cl_spatialRepresentationType.key","size":10}},"availableInServices":{"filters":{"filters":{"availableInViewService":{"query_string":{"query":"+linkProtocol:/OGC:WMS.*/"}},"availableInDownloadService":{"query_string":{"query":"+linkProtocol:/OGC:WFS.*/"}}}}},"th_gemet_tree.default":{"terms":{"field":"th_gemet_tree.default","size":100,"order":{"_key":"asc"},"include":"[^^]+^?[^^]+"}},"th_httpinspireeceuropaeumetadatacodelistPriorityDataset-PriorityDataset_tree.default":{"terms":{"field":"th_httpinspireeceuropaeumetadatacodelistPriorityDataset-PriorityDataset_tree.default","size":100,"order":{"_key":"asc"}}},"tag.default":{"terms":{"field":"tag.default","include":".*","size":10},"meta":{"caseInsensitiveInclude":true}},"th_regions_tree.default":{"terms":{"field":"th_regions_tree.default","size":100,"order":{"_key":"asc"}}},"resolutionScaleDenominator":{"histogram":{"field":"resolutionScaleDenominator","interval":10000,"keyed":true,"min_doc_count":1},"meta":{"collapsed":true}},"creationYearForResource":{"histogram":{"field":"creationYearForResource","interval":5,"keyed":true,"min_doc_count":1},"meta":{"collapsed":true}},"OrgForResource":{"terms":{"field":"OrgForResource","include":".*","size":15},"meta":{"caseInsensitiveInclude":true}},"cl_maintenanceAndUpdateFrequency.key":{"terms":{"field":"cl_maintenanceAndUpdateFrequency.key","size":10},"meta":{"collapsed":true}}},"filters":null,"sortbyValues":[{"sortBy":"relevance","sortOrder":""},{"sortBy":"dateStamp","sortOrder":"desc"},{"sortBy":"createDate","sortOrder":"desc"},{"sortBy":"resourceTitleObject.default.keyword","sortOrder":""},{"sortBy":"rating","sortOrder":"desc"},{"sortBy":"popularity","sortOrder":"desc"}],"sortBy":"relevance","resultViewTpls":[{"tplUrl":"../../catalog/components/search/resultsview/partials/viewtemplates/grid.html","tooltip":"Grid","icon":"fa-th"},{"tplUrl":"../../catalog/components/search/resultsview/partials/viewtemplates/list.html","tooltip":"List","icon":"fa-bars"}],"resultTemplate":"../../catalog/components/search/resultsview/partials/viewtemplates/grid.html","formatter":{"list":[{"label":"defaultView","url":""},{"label":"full","url":"/formatters/xsl-view?root=div&view=advanced"}],"defaultUrl":""},"downloadFormatter":[{"label":"exportMEF","url":"/formatters/zip?withRelated=false","class":"fa-file-zip-o"},{"label":"exportPDF","url":"/formatters/xsl-view?output=pdf&language=${lang}","class":"fa-file-pdf-o"},{"label":"exportXML","url":"/formatters/xml","class":"fa-file-code-o"}],"grid":{"related":["parent","children","services","datasets"]},"linkTypes":{"links":["LINK","kml"],"downloads":["DOWNLOAD"],"layers":["OGC","ESRI:REST"],"maps":["ows"]},"isFilterTagsDisplayedInSearch":true,"showMapInFacet":false,"showStatusFooterFor":"historicalArchive,obsolete,superseded","usersearches":{"enabled":false,"includePortals":true,"displayFeaturedSearchesPanel":false},"savedSelection":{"enabled":false},"addWMSLayersToMap":{"urlLayerParam":""},"exactMatchToggle":true},"map":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.search#/map","externalViewer":{"enabled":false,"enabledViewAction":false,"baseUrl":"http://www.example.com/viewer","urlTemplate":"http://www.example.com/viewer?url=${service.url}&type=${service.type}&layer=${service.title}&lang=${iso2lang}&title=${md.defaultTitle}","openNewWindow":false,"valuesSeparator":","},"is3DModeAllowed":false,"isSaveMapInCatalogAllowed":true,"isExportMapAsImageEnabled":false,"storage":"sessionStorage","bingKey":"","listOfServices":{"wms":[],"wmts":[]},"projection":"EPSG:3857","projectionList":[{"code":"urn:ogc:def:crs:EPSG:6.6:4326","label":"WGS84 (EPSG:4326)"},{"code":"EPSG:3857","label":"Google mercator (EPSG:3857)"}],"switcherProjectionList":[{"code":"EPSG:3857","label":"Google mercator (EPSG:3857)"}],"disabledTools":{"processes":false,"addLayers":false,"projectionSwitcher":false,"layers":false,"legend":false,"filter":false,"contexts":false,"print":false,"mInteraction":false,"graticule":false,"mousePosition":true,"syncAllLayers":false,"drawVector":false},"graticuleOgcService":{},"map-viewer":{"context":"../../map/config-viewer.xml","extent":[0,0,0,0],"layers":[]},"map-search":{"context":"../../map/config-viewer.xml","extent":[0,0,0,0],"layers":[]},"map-editor":{"context":"","extent":[0,0,0,0],"layers":[{"type":"osm"}]},"autoFitOnLayer":false},"geocoder":{"enabled":true,"appUrl":"https://secure.geonames.org/searchJSON"},"recordview":{"isSocialbarEnabled":true,"showStatusWatermarkFor":"historicalArchive,obsolete,superseded","showStatusTopBarFor":"","enabled":true},"editor":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.edit","isUserRecordsOnly":false,"minUserProfileToCreateTemplate":"","isFilterTagsDisplayed":false,"fluidEditorLayout":true,"createPageTpl":"../../catalog/templates/editor/new-metadata-horizontal.html","editorIndentType":"","allowRemoteRecordLink":true,"facetConfig":{"resourceType":{"terms":{"field":"resourceType","size":20}},"cl_status.key":{"terms":{"field":"cl_status.key","size":15}},"sourceCatalogue":{"terms":{"field":"sourceCatalogue","size":15}},"valid":{"terms":{"field":"valid","size":10}},"valid_inspire":{"terms":{"field":"valid_inspire","size":10}},"groupOwner":{"terms":{"field":"groupOwner","size":10}},"recordOwner":{"terms":{"field":"recordOwner","size":10}},"groupPublished":{"terms":{"field":"groupPublished","size":10}},"documentStandard":{"terms":{"field":"documentStandard","size":10}},"isHarvested":{"terms":{"field":"isHarvested","size":2}},"isTemplate":{"terms":{"field":"isTemplate","size":5}},"isPublishedToAll":{"terms":{"field":"isPublishedToAll","size":2}},"isValid":{"terms":{"field":"isValid","size":10}},"isValidInspire":{"terms":{"field":"isValidInspire","size":10}}}},"admin":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/admin.console","facetConfig":{"availableInServices":{"filters":{"filters":{"availableInViewService":{"query_string":{"query":"+linkProtocol:/OGC:WMS.*/"}},"availableInDownloadService":{"query_string":{"query":"+linkProtocol:/OGC:WFS.*/"}}}}},"cl_hierarchyLevel.key":{"terms":{"field":"cl_hierarchyLevel.key"},"meta":{"vega":"arc"}},"tag.default":{"terms":{"field":"tag.default","size":10},"meta":{"vega":"arc"}}}},"authentication":{"enabled":true,"signinUrl":"../../{{node}}/{{lang}}/catalog.signin?casLogin","signoutUrl":"../../signout"},"page":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.search#/page"},"signin":{"enabled":true,"appUrl":"../../{{node}}/{{lang}}/catalog.signin?casLogin"},"signout":{"appUrl":"../../signout"}}}'

    echo "INSERT INTO settings_ui (\"id\", \"configuration\") VALUES ('srv', '${ui_configuration}');" >> ${JETTY_BASE}/webapps/geonetwork/WEB-INF/classes/setup/sql/data/custom-data-db-default.sql

    if [[ -n $ADMIN_USERS ]]; then
      echo "Create admin users"
      #touch ${JETTY_BASE}/webapps/geonetwork/WEB-INF/classes/setup/sql/data/data-sib-custom.sql
      id=2
      for user in $ADMIN_USERS; do
        echo "  - $user"
        echo "INSERT INTO Users (id, username, password, name, surname, profile, kind, organisation, security, authtype, isenabled) VALUES  ($id,'$user','46e44386069f7cf0d4f2a420b9a2383a612f316e2024b0fe84052b0b96c479a23e8a0be8b90fb8c2','$user','',0,'','','','', 'y');" \
          >> ${JETTY_BASE}/webapps/geonetwork/WEB-INF/classes/setup/sql/data/custom-data-db-default.sql
        ((++id)) # increment id
      done
    fi

  fi

  if [[ "$ENABLE_FLAT_FORM" == "yes" ]]; then
    echo "Configuring flat form (ISO 19139 metadata edition)."
    # Add the flat form config
    cp -r /custom-conf/flat-form/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139/
    # Use the less styles specific to flat form
    printf '\n@import "gn_editor_custom_sib.less";' >> ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/gn_editor_default.less
  fi

  # Customize the styles
  echo "Customizing styles (less files)"
  cp /custom-conf/less/* ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/
  printf '\n@import "gn_navbar_custom_sib.less";' >> ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/gn_navbar_default.less
  printf '\n@import "gn_search_custom_sib.less";' >> ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/gn_search_default.less
  printf '\n@import "gn_editor_custom_sib.less";' >> ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/gn_editor_default.less

  # Configure then add webcomponent menu snippet in xslt/base-layout.xsl (global layout)
  if [[ -n $NF_MENU_URL ]]; then
    echo "Adding NatureFrance.fr's menu and footer using WebComponents"

    cp /custom-conf/base-layout.xsl ${JETTY_BASE}/webapps/geonetwork/xslt/
    #cat /custom-conf/html/header-web-component-snippet.html ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/templates/index.html | tee ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/templates/index.html
    # sed -i '/<div data-gn-alert-manager=""><\/div>/ r /custom-conf/html/header-web-component-snippet.html' ${JETTY_BASE}/webapps/geonetwork/xslt/base-layout.xsl
    # sed -i '/<xsl:apply-templates mode="content" select="."\/>/ r /custom-conf/html/footer-web-component-snippet.html' ${JETTY_BASE}/webapps/geonetwork/xslt/base-layout.xsl
    # Insert the footer markup only after 2nd occurrence of the `<xsl:apply-templates mode="content" select="."/>` Make it appear only on public pages
    # awk 'BEGIN {t=0}; { print };/<xsl:apply-templates mode="content" select="."\/>/ {t++; if ( t==2 ) { print "\n            <xsl:if test=\"$angularApp = \047gn_search\047 or $angularApp = \047gn_viewer\047 or $angularApp = \047gn_formatter_viewer\047\">\n              <sib-footer src=\"SET_NATUREFRANCE_MENU_URL_HERE\"></sib-footer>\n            </xsl:if>" } }' ${JETTY_BASE}/webapps/geonetwork/xslt/base-layout.xsl > /tmp/base-layout.xsl \
    #    && mv /tmp/base-layout.xsl ${JETTY_BASE}/webapps/geonetwork/xslt/base-layout.xsl
    sed -i "s|SET_NATUREFRANCE_MENU_URL_HERE|$NF_MENU_URL|g" ${JETTY_BASE}/webapps/geonetwork/xslt/base-layout.xsl
    cp /custom-conf/js/header-web-component-snippet.js ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/
    # Tell wro4j not to try to compile our code snippet (which uses es6, while wro4j sticks with es5 javascript, so it wouldn't compile)
    # => insert `<jsSource webappPath="/catalog/views/default/header-web-component-snippet.js" minimize="false"/>` in the libs list
    sed -i '/<jsSource webappPath="\/catalog\/lib\/dom-to-image\/dom-to-image.min.js" minimize="false"\/>/i     <jsSource webappPath="\/catalog\/views\/default\/header-web-component-snippet.js" minimize="false"\/>' ${JETTY_BASE}/webapps/geonetwork/WEB-INF/classes/web-ui-wro-sources.xml
    # cat ${JETTY_BASE}/webapps/geonetwork/WEB-INF/classes/web-ui-wro-sources.xml
  fi

  # Apply translation for custom facets based on SIB thesauri
  sed -i '2i "facet-th_dpsir": "DPSIR",\n  "facet-th_opendata": "Ouverture des données",\n  "facet-th_politiquepublique": "Politique publique",\n  "facet-th_thematiques": "Thématiques",\n  "facet-th_datatype": "Type de données",\n  "facet-th_ebv": "Variables essentielles de biodiversité",\n' ${JETTY_BASE}/webapps/geonetwork/catalog/locales/fr-v4.json

  echo "Custom configuration applied" > /custom-conf/applied
fi

# Chain and run geonetwork entrypoint
exec /geonetwork-entrypoint.sh "$@"
