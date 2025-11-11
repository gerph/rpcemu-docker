#!/bin/bash
##
# Synchronise the window and server sizes to the emulator.
#

export DISPLAY=:1

w=$1
h=$2

if [[ "$w" == '' ]] ; then
    if [[ -f "/riscos/_Resolution,ffd" ]] ; then
        read w h < /riscos/_Resolution,ffd
        rm /riscos/_Resolution,ffd
    else
        # No size given, so give up.
        exit
    fi
fi

echo "Changing resolution: $w x $h"
w=$((w + 1))
h=$((h + 43))
mode=$(cvt $w $h | grep Modeline | sed -e "s/Modeline *//" -e 's/"//g')
xrandr --output VNC-0 --newmode $mode 2> /dev/null
name=${mode%% *}
xrandr --addmode VNC-0 $name 2> /dev/null
xrandr --output VNC-0 --mode $name
wmctrl -r RPCEmu -e 0,0,0,$w,$h
wmctrl -r RPCEmu -b remove,fullscreen

