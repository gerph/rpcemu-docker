ARG BASE_DOCKER_TAG=latest

FROM gerph/rpcemu-base:${BASE_DOCKER_TAG} AS builder

ARG RPCEMU_VERSION=0.9.3

# Install ROM image (and disk image if necessary)

# Downloads from GDrive
RUN if [ "$RPCEMU_VERSION" = '0.9.3' ] ; then \
        BUNDLE_ID=1YwOdxeCl4IFJewydkEYf53xHgHQuB0he ; \
    elif [ "$RPCEMU_VERSION" = '0.9.4' ] ; then \
        BUNDLE_ID=1EQXtikBr6tOsybTZz0pAKOffTAsVXrGR ; \
    elif [ "$RPCEMU_VERSION" = '0.9.5' ] ; then \
        BUNDLE_ID=1uIAUIB8wuixm2-49bXQSvnLjdeN8ePaz ; \
    else \
        echo "Unsupported RPCEMU_VERSION: $RPCEMU_VERSION" ; \
        exit 1 ; \
    fi && \
    gdown -O rpcemu-bundle.zip "https://drive.google.com/uc?id=${BUNDLE_ID}" && \
    unzip -q rpcemu-bundle.zip && \
    rsync -a "RPCEmu - Direct/hostfs"/* /riscos/ && \
    rsync -a "RPCEmu - Direct/roms"/* /riscos-roms/ && \
    cp "RPCEmu - Direct"/cmos.ram rpcemu/ && \
    cp "RPCEmu - Direct"/rpc.cfg rpcemu/ && \
    rm -rf rpcemu-bundle.zip "RPCEmu - Direct/"

ADD --chown=riscos:riscos bash_profile /home/riscos/.bash_profile

# Ensure that the sound is turned off - we don't have sound in the docker container
RUN sed -i s/sound_enabled=1/sound_enabled=0/ rpcemu/rpc.cfg


FROM ubuntu:24.04

ARG RPCEMU_VERSION

# Add user we're going to run under (without a password)
# and set up /riscos to be the HostFS directory.
RUN useradd riscos && \
    mkdir -p /home/riscos && \
    chown -R riscos:riscos /home/riscos && \
    mkdir -p /rpcemu /riscos /riscos-roms && \
    chown riscos:riscos /rpcemu /riscos /riscos-roms && \
    ln -s /rpcemu /home/riscos/rpcemu && \
    ln -s /riscos /rpcemu/hostfs && \
    ln -s /riscos-roms /rpcemu/roms

USER root
RUN export DEBIAN_FRONTEND="noninteractive" ; \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tigervnc-standalone-server fluxbox \
                        libqt5gui5 \
                        libqt5multimedia5-plugins \
                        xcvt x11-utils wmctrl \
                     && \
    rm -rf ~/.cache/pip /var/lib/apt/lists

USER riscos
COPY --from=builder /home/riscos /home/riscos
COPY --from=builder /rpcemu /rpcemu
COPY --from=builder /riscos /riscos
COPY --from=builder /riscos-roms /riscos-roms
COPY VNCResize/rm32/VNCResize,ffa /riscos/!Boot/Choices/Boot/PreDesk/VNCResize,ffa

USER root
RUN chown -R riscos:riscos /rpcemu /riscos /riscos-roms
COPY rpcemu-start.sh /usr/local/bin/rpcemu-start.sh
COPY rpcemu-sync-size.sh /usr/local/bin/rpcemu-sync-size.sh
RUN chmod 755 /usr/local/bin/rpcemu-*

USER riscos

# Fix up:
#   * The display resolution to make the mode larger
RUN sed -i 's/WimpMode.*/WimpMode X1024 Y768 C32K/' /riscos/!Boot/Choices/Boot/PreDesk/Configure/Monitor,feb

WORKDIR /riscos
ENV PATH="$PATH:/rpcemu"
ENV RPCEMU_VERSION="$RPCEMU_VERSION"
ENV RO_VERSION=5

CMD ["/usr/local/bin/rpcemu-start.sh"]
EXPOSE 5901
