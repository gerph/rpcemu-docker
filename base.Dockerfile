##
# Base dockerfile for RPCEmu.
#
# Creates a user 'riscos' which contains the RPCEmu and VNC configuration.
#
# Directories in image:
#   /rpcemu - Installation of RPCEmu, with:
#                `hostfs` linked to `/riscos`
#                `roms` linked to `/riscos-roms`
#   /riscos - The RPCEmu `hostfs` directory
#   /riscos-roms - a directory containing ROMs

FROM ubuntu:24.04

ARG RPCEMU_VERSION=0.9.3

# Add user we're going to run under (without a password)
RUN useradd riscos && \
    mkdir -p /home/riscos && \
    chown -R riscos:riscos /home/riscos

# Install the VNC server, with the build system and libraries.
# The password for the VNC server is 'password'.
USER root
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive"  apt-get install -y tigervnc-standalone-server fluxbox locales \
                        build-essential \
                        qtbase5-dev \
                        qtmultimedia5-dev \
                        libqt5multimedia5-plugins \
                        python3-pip \
                        wget unzip rsync \
                     && \
    locale-gen en_US.UTF-8 && \
    mkdir -p /home/riscos/.vnc && \
    echo "29g8/XJ6FFg=" | base64 -d > /home/riscos/.vnc/passwd && \
    chown -R riscos:riscos /home/riscos/.vnc && \
    chmod 0600 /home/riscos/.vnc/passwd && \
    pip3 install --break-system-packages gdown && \
    rm -rf ~/.cache/pip /var/lib/apt/lists && \
    mkdir -p /rpcemu /riscos /riscos-roms && \
    chown riscos:riscos /rpcemu /riscos /riscos-roms && \
    ln -s /rpcemu /home/riscos/rpcemu


# Build RPCEmu
WORKDIR /home/riscos
USER riscos
RUN cd /tmp && \
    wget -O rpcemu-${RPCEMU_VERSION}.tar.gz "https://www.marutan.net/rpcemu/cgi/download.php?sFName=${RPCEMU_VERSION}/rpcemu-${RPCEMU_VERSION}.tar.gz" && \
    tar zxf rpcemu-${RPCEMU_VERSION}.tar.gz && \
    cd rpcemu-${RPCEMU_VERSION}/src/qt5 && \
        if [ "$(uname -p)" != 'aarch64' ] ; then sed -i 's/CONFIG += debug_and_release/CONFIG += debug_and_release dynarec/' rpcemu.pro ; fi && \
        ./buildit.sh && \
        make && \
        cd ../.. && \
        rm -rf src && \
        cd .. && \
    mv rpcemu-${RPCEMU_VERSION}/* /rpcemu/ && \
    mv /rpcemu/hostfs/* /riscos/ && rmdir /rpcemu/hostfs && \
    mv /rpcemu/roms/* /riscos-roms/ && rmdir /rpcemu/roms && \
    ln -s /riscos /rpcemu/hostfs && \
    ln -s /riscos-roms /rpcemu/roms && \
    rm -rf /tmp/rpcemu-${RPCEMU_VERSION}.tar.gz /tmp/rpcemu-${RPCEMU_VERSION}

RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu/rpc.cfg

# Configure the fluxbox environment to hide most parts of it.
ADD --chown=riscos:riscos fluxbox-init /home/riscos/.fluxbox/init
ADD --chown=riscos:riscos fluxbox-menu /home/riscos/.fluxbox/menu
ADD --chown=riscos:riscos fluxbox-windowmenu /home/riscos/.fluxbox/windowmenu

ENV PATH="$PATH:/rpcemu"
CMD ["bash", "-c", "export DISPLAY=:1 USER=riscos && vncserver -geometry 1280x1024 -localhost no >/dev/null 2>/dev/null && cd rpcemu && ./rpcemu-recompiler"]
EXPOSE 5901
