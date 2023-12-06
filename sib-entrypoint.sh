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
    ui_configuration='{  "mods": {    "authentication": {      "signinUrl": "../../{{node}}/{{lang}}/catalog.signin?casLogin"    }  }}'

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

  # Add the fix for DCAT support (fix license support)
  # TODO: get it into core-gn codebase and remove this when https://github.com/geonetwork/core-geonetwork/pull/7176 is merged
  cp -r /custom-conf/dcat-support/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/data/config/schema_plugins/iso19139/

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


  # Fix translations
  cp /custom-conf/locales/* ${JETTY_BASE}/webapps/geonetwork/catalog/locales/


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
  # fr
  sed -i '2i "facet-th_dpsir": "DPSIR",\n  "facet-th_opendata": "Ouverture des données",\n  "facet-th_politiquepublique": "Politique publique",\n  "facet-th_thematiques": "Thématiques",\n  "facet-th_datatype": "Type de données",\n  "facet-th_ebv": "Variables essentielles de biodiversité",\n  "facet-th_pressref": "Pressions exercées sur la biodiversité",\n' ${JETTY_BASE}/webapps/geonetwork/catalog/locales/fr-v4.json
  # en
  sed -i '2i "facet-th_dpsir": "DPSIR",\n  "facet-th_opendata": "Data openness",\n  "facet-th_politiquepublique": "Public policy",\n  "facet-th_thematiques": "Themes",\n  "facet-th_datatype": "Data types",\n  "facet-th_ebv": "Essential biodiversity variables",\n  "facet-th_pressref": "Pressures on biodiversity",\n' ${JETTY_BASE}/webapps/geonetwork/catalog/locales/en-v4.json

  echo "Custom configuration applied" > /custom-conf/applied
fi

# Chain and run geonetwork entrypoint
exec /geonetwork-entrypoint.sh "$@"
