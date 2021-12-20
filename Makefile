SHELL := /bin/bash
IMAGE=pigeosolutions/sib-geonetwork
REV=`git rev-parse --short HEAD`
DATE=`date +%Y%m%d-%H%M`
VERSION=4.0.5

all: pull-deps docker-build docker-push

pull-deps:
	docker pull geonetwork:${VERSION}

docker-build:
	docker build -t ${IMAGE}:latest . ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${VERSION}-${DATE}-${REV} ;\
	echo tagged ${IMAGE}:${VERSION}-${DATE}-${REV}

docker-push:
	docker push ${IMAGE}:latest ;\
	docker tag  ${IMAGE}:latest ${IMAGE}:${VERSION}-${DATE}-${REV} ;\
	docker push ${IMAGE}:${VERSION}-${DATE}-${REV}

docker-run:
	docker run -e ES_HOST=elasticsearch geonetwork:${VERSION}
