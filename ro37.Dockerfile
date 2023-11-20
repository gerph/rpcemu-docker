ARG BASE_DOCKER_TAG

FROM gerph/rpcemu-base:${BASE_DOCKER_TAG} AS builder

# 0.9.3 version:
#ARG BUNDLE_ID=19XLe77_VabVzScjzEH-_23fr0xoLndkn
# 0.9.4 version:
ARG BUNDLE_ID=12V6sRpX6wia7z7D4qcmzyXMmdWAhra60

# Install ROM image (and disk image if necessary)

# Downloads from GDrive
RUN gdown -O rpcemu-bundle.zip "https://drive.google.com/uc?id=${BUNDLE_ID}" && \
    unzip -q rpcemu-bundle.zip && \
    rsync -a "RPCEmu - 371/hostfs"/* /riscos/ && \
    rsync -a "RPCEmu - 371/roms"/* /riscos-roms/ && \
    cp "RPCEmu - 371"/cmos.ram /rpcemu/ && \
    cp "RPCEmu - 371"/rpc.cfg /rpcemu/ && \
    rm -rf rpcemu-bundle.zip "RPCEmu - 371/"

ADD --chown=riscos:riscos bash_profile /home/riscos/.bash_profile

# Ensure that the sound is turned off - we don't have sound in the docker container
RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu/rpc.cfg


FROM ubuntu:20.04

# Add user we're going to run under (without a password)
# and set up /riscos to be the HostFS directory.
RUN adduser riscos && \
    mkdir -p /home/riscos && \
    chown -R riscos:riscos /home/riscos && \
    mkdir -p /rpcemu /riscos /riscos-roms && \
    chown riscos:riscos /rpcemu /riscos /riscos-roms && \
    ln -s /rpcemu /home/riscos/rpcemu && \
    ln -s /riscos /rpcemu/hostfs && \
    ln -s /riscos-roms /rpcemu/roms

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive"  apt-get install -y tigervnc-standalone-server fluxbox \
                        libqt5gui5 \
                        libqt5multimedia5-plugins \
                     && \
    rm -rf ~/.cache/pip /var/lib/apt/lists


USER riscos
COPY --from=builder /home/riscos /home/riscos
COPY --from=builder /rpcemu /rpcemu
COPY --from=builder /riscos /riscos
COPY --from=builder /riscos-roms /riscos-roms

# Fix up:
#   * The display resolution to make the mode larger
#   * The background to not include the now-defunct Acorn.
RUN sed -i 's/WimpMode.*/WimpMode X1024 Y768 C32K/' /riscos/!Boot/Choices/Boot/PreDesk/Configure/VRAM,feb && \
    sed -i 's/Backdrop.*/Backdrop -tile BootResources:Configure.Textures.T6/' /riscos/!Boot/Choices/Boot/Tasks/Configure,feb

WORKDIR /riscos
ENV PATH "$PATH:/rpcemu"
CMD export DISPLAY=:1 USER=riscos && vncserver -geometry 1280x1024 -localhost no >/dev/null 2>/dev/null && cd /rpcemu && ./rpcemu-recompiler
EXPOSE 5901
