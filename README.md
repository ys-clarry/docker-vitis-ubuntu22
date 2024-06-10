# Dockerfile for Xilinx Vitis on Ubuntu (22)

## Disclaimers
- You should agree to AMD/Xilinx's [EULAs](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Running-the-Installer) before installation.
- I do not guarantee the normal operation of this scripts.
  - My used toolkit version is `2024.1`. Different version may cause error.
- The license of original dockerfile script is unknown, please contact me if related problems arose.
  - Based on laysakura's [scripts](https://github.com/laysakura/docker-ubuntu-vivado)
  - Above is based on Tosainu's [blog](https://blog.myon.info/entry/2018/09/15/install-xilinx-tools-into-docker-container/)

## Before installation
- Register the ID on AMD's website and download Web installer from there, put it on this folder.
  - Set the filename to `XILINX_INSTALLER` of `Dockerfile` when differs.
- Create authentication token `wi_authentication_key` before making containers.
  - This is done by `sh your_downloaded_xilinx_web_installer.bin -- -b AuthTokenGen`, and the key will be in `~/.Xilinx` of host machine.
  - Copy `~/.Xilinx/wi_authentication_key` into here (the folder same to `Dockerfile`).

## Tips
- With this config `Vitis` is installed. If you need only `Vivado` do generate the config (`-- -b ConfigGen`) by yourself.
- To select devkit(s) of specific FPGA series change `Modules` option of `install_config.txt`.

## Installation
- Do `docker image build -t ubuntu22-vivado .`

## Using
- Give X11 privillage from docker using `xhost +si:localuser:$(whoami)` ... if with wayland you'd need `xorg-xhost`.
- Then run the container like below, then call `vivado` or `vitis`

```
docker container run -it --rm \
    -e USER_ID=${UID} \
    -e DISPLAY \
    -e XDG_RUNTIME_DIR \
    -e DBUS_SESSION_BUS_ADDRESS \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v /run/user/${UID}:/run/user/${UID}:rw \
    -v ~/work/localhost/vivado:/work \
    -w /work \
    ubuntu22-vivado
```

## Caveats
- Not all the functionalities are tested.

## Changelog
- 2024/06/09
  - Ubuntu base image is Jammy (22), and I've replaced some packages
  - gosu is installed using apt. (but do I really need this?)
