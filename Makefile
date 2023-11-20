# Build all the docker files

RPCEMU_VERSION ?= 0.9.4
BASE_DOCKER_TAG ?= latest

all: base ro37 ro5

base:
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-base:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f base.Dockerfile .

ro37: base
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-3.7:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro37.Dockerfile .

ro5: base
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-5:${BASE_DOCKER_TAG} --build-arg BASE_DOCKER_TAG=${BASE_DOCKER_TAG} --build-arg RPCEMU_VERSION=${RPCEMU_VERSION} -f ro5.Dockerfile .
