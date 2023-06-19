ARG VERSION=4.2.4
FROM geonetwork:${VERSION}

MAINTAINER Jean Pommier "jp@pi-geosolutions.fr"

# Customize the official GN image, to set SIB-specific configuration
# More about SIB: https://naturefrance.fr/systeme-information-biodiversite

ENV GEONETWORK_URL="http://localhost/geonetwork"
ENV ENABLE_CAS=no \
    CAS_BASE_URL="" \
    ADMIN_USERS="" \
    ENABLE_FLAT_FORM=no \
    NF_MENU_URL=""

COPY --chown=jetty:jetty ./custom-conf/ /custom-conf/

COPY --chown=jetty:jetty ./sib-entrypoint.sh /sib-entrypoint.sh
RUN chmod +x /sib-entrypoint.sh
ENTRYPOINT ["/sib-entrypoint.sh"]

# Security "improvements" overlays
USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get -y remove curl
USER jetty
