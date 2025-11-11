# Build all the docker files

RPCEMU_VERSION ?= 0.9.5
BASE_DOCKER_TAG ?= latest

ATTEST=--attest type=provenance,mode=max

all: base ro37 ro5

base:
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-base:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f base.Dockerfile .

ro37: base
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-3.7:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro37.Dockerfile .

ro5: base
	DOCKER_BUILDKIT=1 docker buildx build ${ATTEST} -t gerph/rpcemu-5:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro5.Dockerfile .

riscos-build-online:

