#!/bin/bash
set -e

# Enable CAS
sed -i "s|<!--<import resource="config-security-cas.xml"/>-->|<import resource="config-security-cas.xml"/>|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.xml"
sed -i "s|<!--<import resource="config-security-cas-database.xml"/>-->|<import resource="config-security-cas-database.xml"/>|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.xml"

# Configure CAS
sed -i "s|cas.baseURL=.*|cas.baseURL=https://test-cas-patrinat.mnhn.fr/auth|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
sed -i "s|cas.ticket.validator.url=.*|cas.ticket.validator.url=https://test-cas-patrinat.mnhn.fr/auth|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
sed -i "s|cas.login.url=.*|cas.login.url=https://test-cas-patrinat.mnhn.fr/auth/login|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"
sed -i "s|cas.logout.url=.*|cas.logout.url=https://test-cas-patrinat.mnhn.fr/auth/logout?service=\${geonetwork.https.url}/|" "${JETTY_BASE}/webapps/geonetwork/WEB-INF/config-security/config-security.properties"


# Chain and run geonetwork entrypoint
exec /geonetwork-entrypoint.sh "$@"
