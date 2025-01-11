#!/bin/bash
##
# Start the RPCEmu system.

export DISPLAY=:1
export USER=riscos

# Prevent the startup from reporting that it cannot use hardware drivers
export LIBGL_ALWAYS_SOFTWARE=1

# Ensure that we have a runtime directory
export XDG_RUNTIME_DIR=$HOME/.run
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

# Start the VNC server
vncserver -name "RPCEmu $RPCEMU_VERSION, RISC OS $RO_VERSION" \
          -geometry 1280x1024 \
          -localhost no \
          >/dev/null 2>/dev/null

cd /rpcemu
./rpcemu-recompiler
