# RPCEmu in docker with VNC server

## Introduction

This repository contains the docker build commands for the Docker hub
repositories:

* https://hub.docker.com/r/gerph/rpcemu-base
* https://hub.docker.com/r/gerph/rpcemu-5
* https://hub.docker.com/r/gerph/rpcemu-3.7

These docker images contain:

* An Ubuntu 24.04 OS.
* A VNC server.
* An installation of RPCEmu.
* (depending on the container) The RISC OS 5 or RISC OS 3.7 images from https://www.marutan.net/rpcemu/easystart.html.
* A small module to allow for VNC server resizes on mode change.

## Building

To build these images locally:

```
make
```

To build individual images, use the targets `base`, `ro37`, or `ro5`.

By default this will use version 0.9.5 of RPCEmu. Adding RPCEMU_VERSION to the `make` command will select a different version of RPCEmu. Valid values are:

* 0.9.4
* 0.9.5 (default)
* extended (RPCEmu debugger)

## RPCEmu debugger

The extended version uses the work by Andrew Timmins on his [rpcemu-extended](https://github.com/andrewtimmins/rpcemu-extended) fork of RPCEmu (forked from 0.9.5). Specifically, this uses commit [48da8c6](https://github.com/andrewtimmins/rpcemu-extended/commit/48da8c655a1ffa456f1174b36f55868467805383). This includes his work to add a Machine Inspector to RPCEmu that enables debugging.

A small patch is included in this repository to patch `src/qt5/machine_window_inspector.cpp` so that the Machine Inspector window always stays on top but allows dialog boxes to be top-most (i.e. when resetting RPCEmu). This prevents the Machine Inspector hiding behind the main RPCEmu window when clicking around inside of it.

## Usage

To use the images:

```
docker run -it --init --rm -p 5901:5901 gerph/rpcemu-3.7
docker run -it --init --rm -p 5901:5901 gerph/rpcemu-5
```

To use the RPCEmu extended version, use the `debug` tag:

```
docker run -it --init --rm -p 5901:5901 gerph/rpcemu-3.7:debug
docker run -it --init --rm -p 5901:5901 gerph/rpcemu-5:debug
```

Then use a VNC client to connect to VNC on localhost port 1 (which might
be specified as :1 or :5901 depending on your client). A password is
required, which is configured to be `password`.

Closing RPCEmu will terminate the docker container.

To access a host directory from within the container, start the docker process with a volume mapping, thus:

```
docker run -it --init -v $PWD:/riscos/Shared --rm -p 5901:5901 gerph/rpcemu-3.7
docker run -it --init -v $PWD:/riscos/Shared --rm -p 5901:5901 gerph/rpcemu-5
```

This shares your current working directory as a directory called
'Shared' at the root of the HostFS disc.

You can replace the entire HostFS disc by specifying a mount point at `/riscos`, eg:

```
docker run -it --init -v $PWD:/riscos --rm -p 5901:5901 gerph/rpcemu-3.7
```

## Override volume

It is possible to replace the ROMs and/or HostFS contents before RPCEmu starts by mounting an override volume at `/override`. This is useful for supplying nightly builds or custom configurations without rebuilding the image.

The override volume may contain the following subdirectories:

* `roms/` - replaces the contents of `/riscos-roms` (always a full replace).
* `hostfs/` - replaces or merges into `/riscos`, depending on the `OVERRIDE_MERGE` environment variable:
  * By default (replace): the contents of `/riscos` are replaced with those from `hostfs/`. The `VNCResize` module installed by the image at `!Boot/Choices/Boot/PreDesk/VNCResize,ffa` is always preserved, even in replace mode.
  * If `OVERRIDE_MERGE=1`: the contents of `hostfs/` are merged into `/riscos`, preserving existing files.

Each subdirectory is optional. If a subdirectory is absent or empty, the corresponding target is left untouched.

For example, to supply a nightly RISC OS 5 ROM and HardDisc4, use the `get-ro5-nightly.sh` script to populate a local `ro5-nightly/` directory, then mount it as the override volume and merge HardDisc4:

```
./get-ro5-nightly.sh
docker run -it --init --rm -p 5901:5901 -v $PWD/ro5-nightly:/override -e OVERRIDE_MERGE=1 gerph/rpcemu-5
```

## Image tags

The following tags (and images) are available on Docker Hub:

* `1` (`gerph/rpcemu-3.7:1`, `gerph/rpcemu-5:1`) - RPCEmu 0.9.3, using the original bundles, Ubuntu 20.04. These images use a different file layout, with the hostfs directory at `/home/riscos/rpcemu/hostfs` instead of `/riscos`.
* `2` (`gerph/rpcemu-3.7:2`, `gerph/rpcemu-5:2`) - RPCEmu 0.9.4, using the 0.9.4 bundles, Ubuntu 20.04.
* `3` (`gerph/rpcemu-3.7:3`, `gerph/rpcemu-5:3`) - RPCEmu 0.9.5, using the 0.9.5 bundles, Ubuntu 24.04.
* `4` (`gerph/rpcemu-3.7:4`, `gerph/rpcemu-5:4`) - RPCEmu 0.9.5, using the 0.9.5 bundles, Ubuntu 24.04, with auto-resize.
* `latest` - same as `4`.
* `debug` (`gerph/rpcemu-3.7:debug`, `gerph/rpcemu-5:debug`) - RPCEmu Extended (forked from 0.9.5), using the 0.9.5 bundles, Ubuntu 24.0.4, with auto-resize.

