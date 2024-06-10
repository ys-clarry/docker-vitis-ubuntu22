# Dockerfile for AMD(Xilinx) Vitis on Ubuntu (22)

## What is this?
- To use AMD's Vivado and/or Vitis (unified IDE) in docker, to enable use these with distros out of support (in my case, Arch).
- I'd like to thank to predecessors. The license of original script is unknown, please contact me if related problems arose.
  - laysakura's [github](https://github.com/laysakura/docker-ubuntu-vivado)
  - Tosainu's [blog](https://blog.myon.info/entry/2018/09/15/install-xilinx-tools-into-docker-container/)

## Disclaimers
- You should agree to AMD's [EULAs](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Running-the-Installer) before installation.
- I do not guarantee the normal operation of this scripts.
  - Not all the functionalities are tested. Connections via USB may not work.
  - My used toolkit version is `2024.1`. Different version may cause error.

## Before installation
1. Register your ID on AMD's website, download (web) installer.bin from there and put it on this folder.
  - Set its filename to `XILINX_INSTALLER` in `Dockerfile` when differs.
  - Also change `TOOLS_VERSION` in `entrypoint.sh` if it's changed.
2. Create authentication token `wi_authentication_key` before making containers.
  - Make it by `sh your_downloaded_xilinx_web_installer.bin -- -b AuthTokenGen`.
  - Copy `~/.Xilinx/wi_authentication_key` into the folder same to `Dockerfile`.

## Installation
- Do `docker image build -t ubuntu22-vivado`. It takes a while.

## Using
- `xhost +si:localuser:$(whoami)` to give X11 privillage from docker.
  - If with wayland `xorg-xhost` is needed.
- Then run the container like below, then call `vivado` or `vitis` in bash.
```
docker container run -it --rm \
    -e USER_ID=${UID} \
    -e DISPLAY \
    -e XDG_RUNTIME_DIR \
    -e DBUS_SESSION_BUS_ADDRESS \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v /run/user/${UID}:/run/user/${UID}:rw \
    -v ~/vivado:/work \
    -w /work \
    ubuntu22-vivado
```
- Notice that container workdir `/work` is in host `~/vivado`, in example.

## Tips
- With this config `Vitis` and `Vivado` are installed. If you need only `Vivado` generate the config (`installer.bin -- -b ConfigGen`) by yourself.
- To select devkit(s) of specific FPGA series change `Modules` option of `install_config.txt`.

## Changelog
- 2024/06/09
  - Ubuntu base image is Jammy (22), and I've replaced some packages
  - gosu is installed using apt.
- 2024/06/10
  - Now the vitis launches inside the container :)
