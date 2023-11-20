# RPCEmu in docker with VNC server

## Introduction

This repository contains the docker build commands for the Docker hub 
repositories:

* https://hub.docker.com/r/gerph/rpcemu-base
* https://hub.docker.com/r/gerph/rpcemu-5
* https://hub.docker.com/r/gerph/rpcemu-3.7

These docker images contain:

* An Ubuntu 20.04 OS.
* A VNC server.
* An installation of RPCEmu.
* (depending on the container) The RISC OS 5 or RISC OS 3.7 images from https://www.marutan.net/rpcemu/easystart.html.

## Building

To build these images locally:

```
make
```

To build individual images, use the targets `base`, `ro37`, or `ro5`.

## Usage

To use the images:

```
docker run -it --rm -p 5901:5901 gerph/rpcemu-3.7
docker run -it --rm -p 5901:5901 gerph/rpcemu-5
```

Then use a VNC client to connect to VNC on localhost port 1 (which might
be specified as :1 or :5901 depending on your client). A password is
required, which is configured to be `password`.

Closing RPCEmu will terminate the docker container.

To access a host directory from within the container, start the docker process with a volume mapping, thus:

```
docker run -it -v $PWD:/riscos/Shared --rm -p 5901:5901 gerph/rpcemu-3.7
docker run -it -v $PWD:/riscos/Shared --rm -p 5901:5901 gerph/rpcemu-5
```

This shares your current working directory as a directory called
'Shared' at the root of the HostFS disc.

You can replace the entire HostFS disc by specifying a mount point at `/riscos`, eg:

```
docker run -it -v $PWD:/riscos --rm -p 5901:5901 gerph/rpcemu-3.7
```
