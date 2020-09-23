FROM ubuntu:20.04

ARG rpcemu_version=0.9.3

# Add user we're going to run under (without a password)
RUN adduser riscos && \
    mkdir -p /home/riscos && \
    chown -R riscos:riscos /home/riscos

# Install the VNC server, with the build system and libraries.
# The password for the VNC server is 'password'.
USER root
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive"  apt-get install -y tightvncserver fluxbox locales \
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
    pip3 install gdown && \
    rm -rf ~/.cache/pip /var/lib/apt/lists


# Build RPCEmu
WORKDIR /home/riscos
USER riscos
RUN wget -O rpcemu-${rpcemu_version}.tar.gz "https://www.marutan.net/rpcemu/cgi/download.php?sFName=${rpcemu_version}/rpcemu-${rpcemu_version}.tar.gz" && \
    tar zxf rpcemu-${rpcemu_version}.tar.gz && \
    cd rpcemu-${rpcemu_version}/src/qt5 && \
        sed -i 's/CONFIG += debug_and_release/CONFIG += debug_and_release dynarec/' rpcemu.pro && \
        ./buildit.sh && \
        make && \
        cd ../.. && \
        rm -rf src && \
        mkdir -p roms hostfs && \
        cd .. && \
    ln -s rpcemu-${rpcemu_version} rpcemu && \
    rm -rf rpcemu-${rpcemu_version}.tar.gz

RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu/rpc.cfg

CMD export DISPLAY=:1 USER=riscos && vncserver >/dev/null 2>/dev/null && cd rpcemu && ./rpcemu-recompiler
EXPOSE 5901
