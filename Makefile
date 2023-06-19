SHELL := /bin/bash
IMAGE=pigeosolutions/sib-geonetwork
SIBIMAGE=outils-patrinat.mnhn.fr/sib-geonetwork
REV=`git rev-parse --short HEAD`
DATE=`date +%Y%m%d-%H%M`
VERSION=4.2.4

all: docker-build docker-push

sib: docker-push-sib

pull-deps:
	docker pull geonetwork:${VERSION}

docker-build:
	docker build -t ${IMAGE}:latest . ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${VERSION}-${DATE}-${REV} ;\
	echo tagged ${IMAGE}:${VERSION}-${DATE}-${REV}

docker-build-local:
	docker build -f Dockerfile-from-war -t ${IMAGE}:latest . ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${VERSION}-${DATE}-${REV} ;\
	echo tagged ${IMAGE}:${VERSION}-${DATE}-${REV}

docker-push:
	docker push ${IMAGE}:latest ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${VERSION}-${DATE}-${REV} ;\
	docker push ${IMAGE}:${VERSION}-${DATE}-${REV}

docker-build-sib:
	docker build -t ${SIBIMAGE}:latest . ;\
	docker tag  ${SIBIMAGE}:latest ${SIBIMAGE}:${VERSION}-${DATE}-${REV} ;\
	echo tagged ${SIBIMAGE}:${VERSION}-${DATE}-${REV}

docker-push-sib: docker-build-sib
	docker push ${SIBIMAGE}:latest ;\
	docker tag  ${SIBIMAGE}:latest ${SIBIMAGE}:${VERSION}-${DATE}-${REV} ;\
	docker push ${SIBIMAGE}:${VERSION}-${DATE}-${REV}

docker-run:
	docker run -e ES_HOST=elasticsearch geonetwork:${VERSION}
