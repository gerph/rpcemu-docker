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

# Apply override volume if present and non-empty
if stat /override/roms/* > /dev/null 2>&1 ; then
    echo "Applying override: /override/roms -> /riscos-roms"
    rsync -a --delete /override/roms/ /riscos-roms/
fi

if stat /override/hostfs/* > /dev/null 2>&1 ; then
    if [ "$OVERRIDE_MERGE" = "1" ] ; then
        echo "Applying override (merge): /override/hostfs -> /riscos"
        rsync -a /override/hostfs/ /riscos/
    else
        echo "Applying override (replace): /override/hostfs -> /riscos"
        rsync -a --delete --exclude='!Boot/Choices/Boot/PreDesk/VNCResize,ffa' /override/hostfs/ /riscos/
    fi
fi

# Start the VNC server
vncserver -name "RPCEmu $RPCEMU_VERSION, RISC OS $RO_VERSION" \
          -geometry 1280x1024 \
          -localhost no \
          >/dev/null 2>/dev/null

# Once a second update the resolution of the session.
(
    while true ; do
        sleep 1
        if [[ -f /riscos/_Resolution,ffd ]] ; then
            rpcemu-sync-size.sh
        fi
    done
) &
disown

cd /rpcemu
if [[ -x rpcemu-recompiler ]] ; then
    rpcemu=rpcemu-recompiler
else
    rpcemu=rpcemu-interpreter
fi
./"${rpcemu}"
