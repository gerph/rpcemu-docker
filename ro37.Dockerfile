FROM gerph/rpcemu-base AS builder

ARG rpcemu_version=0.9.3


# Install ROM image (and disk image if necessary)

# Downloads from GDrive
RUN gdown -O rpcemu-${rpcemu_version}-bundle-371-issue-1-1.zip 'https://drive.google.com/uc?id=19XLe77_VabVzScjzEH-_23fr0xoLndkn' && \
    unzip -q rpcemu-${rpcemu_version}-bundle-371-issue-1-1.zip && \
    rsync -a "RPCEmu - 371/hostfs"/* rpcemu/hostfs/ && \
    rsync -a "RPCEmu - 371/roms"/* rpcemu/roms/ && \
    cp "RPCEmu - 371"/cmos.ram rpcemu/ && \
    cp "RPCEmu - 371"/rpc.cfg rpcemu/ && \
    rm -rf rpcemu-${rpcemu_version}-bundle-371-issue-1-1.zip "RPCEmu - 371/"

ADD --chown=riscos:riscos bash_profile /home/riscos/.bash_profile

# Ensure that the sound is turned off - we don't have sound in the docker container
RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu/rpc.cfg


FROM ubuntu:20.04

# Add user we're going to run under (without a password)
RUN adduser riscos && \
    mkdir -p /home/riscos && \
    chown -R riscos:riscos /home/riscos

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive"  apt-get install -y tigervnc-standalone-server fluxbox \
                        libqt5gui5 \
                        libqt5multimedia5-plugins \
                     && \
    rm -rf ~/.cache/pip /var/lib/apt/lists


USER riscos
COPY --from=builder /home/riscos /home/riscos

WORKDIR /home/riscos
CMD export DISPLAY=:1 USER=riscos && vncserver -geometry 1280x1024 -localhost no >/dev/null 2>/dev/null && cd rpcemu && ./rpcemu-recompiler
EXPOSE 5901
