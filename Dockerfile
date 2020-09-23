FROM ubuntu:20.04


# Add user we're going to run under (without a password)
RUN adduser riscos && \
    mkdir -p /home/riscos/fs && \
    chown -R riscos:riscos /home/riscos/fs


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
RUN wget -O rpcemu-0.9.3.tar.gz "https://www.marutan.net/rpcemu/cgi/download.php?sFName=0.9.3/rpcemu-0.9.3.tar.gz" && \
    tar zxf rpcemu-0.9.3.tar.gz && \
    cd rpcemu-0.9.3/src/qt5 && \
        ./buildit.sh && \
        make && \
        rm -rf src && \
        cd .. && \
    rm -rf rpcemu-0.9.3.tar.gz


# Install ROM image (and disk image if necessary)
RUN mkdir -p rpcemu-0.9.3/roms
# Installs from a local copy:
#ADD --chown=riscos:riscos resources/cmos.ram \
#                          resources/rpc.cfg \
#                          rpcemu-0.9.3/
#ADD --chown=riscos:riscos resources/roms/ROM371 \
#                          resources/roms/roms.txt \
#                          rpcemu-0.9.3/roms/

# Downloads from GDrive
RUN gdown -O rpcemu-0.9.3-bundle-371-issue-1-1.zip 'https://drive.google.com/uc?id=19XLe77_VabVzScjzEH-_23fr0xoLndkn' && \
    unzip -q rpcemu-0.9.3-bundle-371-issue-1-1.zip && \
    rsync -a "RPCEmu - 371/hostfs"/* rpcemu-0.9.3/hostfs/ && \
    rsync -a "RPCEmu - 371/roms"/* rpcemu-0.9.3/roms/ && \
    cp "RPCEmu - 371"/cmos.ram rpcemu-0.9.3/ && \
    cp "RPCEmu - 371"/rpc.cfg rpcemu-0.9.3/ && \
    rm -rf rpcemu-0.9.3-bundle-371-issue-1-1.zip "RPCEmu - 371/"

ADD --chown=riscos:riscos bash_profile /home/riscos/.bash_profile

# Ensure that the sound is turned off - we don't have sound in the docker container
RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu-0.9.3/rpc.cfg

CMD export DISPLAY=:1 USER=riscos && vncserver >/dev/null 2>/dev/null && cd rpcemu-0.9.3 && ./rpcemu-interpreter
EXPOSE 5901
