# Build all the docker files

all: base ro37 ro5

base:
	docker build -t gerph/rpcemu-base -f base.Dockerfile .

ro37: base
	docker build -t gerph/rpcemu-3.7 -f ro37.Dockerfile .

ro5: base
	docker build -t gerph/rpcemu-5 -f ro5.Dockerfile .
