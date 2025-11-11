# Build all the docker files

RPCEMU_VERSION ?= 0.9.5
BASE_DOCKER_TAG ?= latest

ATTEST=--attest type=provenance,mode=max

COMMA = ,
VNCRESIZE = VNCResize/rm32/VNCResize${COMMA}ffa

all: base ro37 ro5

base:
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-base:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f base.Dockerfile .

ro37: base ${VNCRESIZE}
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-3.7:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro37.Dockerfile .

ro5: base ${VNCRESIZE}
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-5:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro5.Dockerfile .


# Building VNCResize
riscos-build-online:
	if [[ "$$(uname -s)" != "Darwin" ]] ; then curl -s -L -o riscos-build-online https://github.com/gerph/robuild-client/releases/download/v0.07/riscos-build-online && chmod +x riscos-build-online ; fi
	if [[ "$$(uname -s)" == "Darwin" ]] ; then ln -sf $$(which riscos-build-online) riscos-build-online ; fi

${VNCRESIZE}: riscos-build-online \
			  VNCResize/Makefile,fe1 \
			  VNCResize/c/module \
			  VNCResize/c/i_screeninfo \
			  VNCResize/cmhg/modhead
	rm -f /tmp/source-archive.zip
	mkdir -p VNCResize/rm32
	cd VNCResize ; zip -q9r /tmp/source-archive.zip c cmhg h Makefile,fe1 VersionNum .robuild.yaml
	./riscos-build-online -i /tmp/source-archive.zip -a off -t 60 -o VNCResize/rm32/VNCResize
