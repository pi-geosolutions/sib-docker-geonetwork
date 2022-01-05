ARG VERSION=4.0.5
FROM geonetwork:${VERSION}

MAINTAINER Jean Pommier "jp@pi-geosolutions.fr"

# Customize the official GN image, to set SIB-specific configuration
# More about SIB: https://naturefrance.fr/systeme-information-biodiversite

ENV GEONETWORK_URL="http://localhost/geonetwork"

# Upgrade log4j2 jar files (keep safe from https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44228)
COPY --chown=jetty:jetty ./log4jfix/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/lib/
RUN rm ${JETTY_BASE}/webapps/geonetwork/WEB-INF/lib/log4j-*-2.7.jar

COPY --chown=jetty:jetty ./custom-conf/ /custom-conf/
# COPY --chown=jetty:jetty ./custom-conf/config-security/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/
# COPY --chown=jetty:jetty ./custom-conf/less/* ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/
#RUN cp /custom-conf/config-security/* ${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/ && \
#  cp /custom-conf/less/* ${JETTY_BASE}/webapps/geonetwork/catalog/views/default/less/ && \
#  cp -pr ${JETTY_BASE}/webapps/geonetwork/catalog/views/default ${JETTY_BASE}/webapps/geonetwork/catalog/views/sib && \
#  cat /custom-conf/html/header-web-component-snippet.html ${JETTY_BASE}/webapps/geonetwork/catalog/views/sib/templates/index.html | tee ${JETTY_BASE}/webapps/geonetwork/catalog/views/sib/templates/index.html

COPY --chown=jetty:jetty ./sib-entrypoint.sh /sib-entrypoint.sh
RUN chmod +x /sib-entrypoint.sh
ENTRYPOINT ["/sib-entrypoint.sh"]
