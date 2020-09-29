# Build all the docker files

all: base ro37 ro5

base:
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-base:latest -f base.Dockerfile .

ro37: base
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-3.7:latest -f ro37.Dockerfile .

ro5: base
	DOCKER_BUILDKIT=1 docker build -t gerph/rpcemu-5:latest -f ro5.Dockerfile .
