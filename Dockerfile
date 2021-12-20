ARG VERSION=4.0.5
FROM geonetwork:${VERSION}

MAINTAINER Jean Pommier "jp@pi-geosolutions.fr"

# Customize the official GN image, to set SIB-specific configuration
# More about SIB: https://naturefrance.fr/systeme-information-biodiversite

COPY --chown=jetty:jetty ./sib-entrypoint.sh /sib-entrypoint.sh
RUN chmod +x /sib-entrypoint.sh
ENTRYPOINT ["/sib-entrypoint.sh"]
