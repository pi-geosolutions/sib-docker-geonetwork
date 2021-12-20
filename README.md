# portail de données du SIB : image docker personnalisée de GeoNetwork

## Compiler
`make docker-build`

## Exécuter
Geonetwork utilise classiquement d'autres services pour bien fonctionner : base de données, moteur d'indexation (elasticsearch).
Il est donc conseillé de le lancer via docker-compose, en utilisant la composition fournie séparément.

Si vous avez un elasticsearch qui tourne déjà quelque part, cependant, vous pouvez lancer GeoNetwork avec la commande docker:
```
docker run --rm -e ES_HOST=elasticsearch pigeosolutions/sib-geonetwork:${GN_VERSION}
```
