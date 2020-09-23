# Bash profile, invoked for login shells.

# include .bashrc if it exists
if [[ -f ~/.bashrc ]] ; then
    source ~/.bashrc
fi

export USER=riscos
vncserver 2> /dev/null >/dev/null || echo "VNC server failed to startup"
export DISPLAY=:1
