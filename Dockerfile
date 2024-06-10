FROM ubuntu:jammy

ARG XILINX_INSTALLER=FPGAs_AdaptiveSoCs_Unified_2024.1_0522_2023_Lin64.bin
ENV XILINX_INSTALLER=${XILINX_INSTALLER}

ENV DEBIAN_FRONTEND noninteractive

RUN \
  sed -i -e "s%http://[^ ]\+%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list && \
  apt update && \
  apt upgrade -y && \
  apt -y --no-install-recommends install \
    gosu \
    ca-certificates curl sudo xorg dbus dbus-x11 ubuntu-gnome-default-settings gtk2-engines \
    fonts-freefont-ttf fonts-ubuntu fonts-droid-fallback lxappearance && \
  apt-get autoclean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN \
  dpkg --add-architecture i386 && \
  apt update && \
  apt -y --no-install-recommends install \
    build-essential git gcc-multilib libc6-dev:i386 ocl-icd-opencl-dev libjpeg62-dev && \
  apt-get autoclean && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/*

# Copy an auth key
RUN mkdir -p /root/.Xilinx
COPY wi_authentication_key /root/.Xilinx
COPY install_config.txt /vivado-installer/
COPY ${XILINX_INSTALLER} /vivado-installer/

RUN \
  sh -x /vivado-installer/${XILINX_INSTALLER} \
    -- \
    --agree 3rdPartyEULA,XilinxEULA \
    --batch Install \
    --config /vivado-installer/install_config.txt && \
  rm -rf /vivado-installer

# Workarounds and tweaks:
# (1) setlocale: LC_ALL: cannot change locale (en_US.UTF-8): No such file or directory -> language-pack-en
# (2) libtinfo.so.5: cannot open shared object file: No such file or directory -> libtinfo5
# (3) libnss3.so: cannot open shared object file: No such file or directory -> libnss3
# (4) libasound.so.2: cannot open shared object file: No such file or directory -> libasound2
# (5) libsecret-1.so.0: cannot open shared object file: No such file or directory -> libsecret-1-0

RUN \
  apt update && \
  apt --no-install-recommends -y install \
    language-pack-en nano \
    libtinfo5 libnss3 libasound2 \
    libsecret-1-0

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash", "-l"]
