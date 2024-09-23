# Dockerfile for AMD (Xilinx) Vitis with Ubuntu Jammy (22)

## What is this?
- To use AMD's Vivado and/or Vitis (unified IDE) in docker, to enable using these in distros whiches are not supported (in my case Arch Linux).
- I'd like to thank to predecessors. The license of original script is unknown, please contact me if related problems arose.
  - laysakura's [github](https://github.com/laysakura/docker-ubuntu-vivado)
  - Tosainu's [blog](https://blog.myon.info/entry/2018/09/15/install-xilinx-tools-into-docker-container/) / [New blog](https://myon.info/blog/2024/07/06/vivado-docker/) / [New Repo](https://github.com/Tosainu/docker-vivado)

## Disclaimers
- You should agree to AMD's [EULAs](https://docs.amd.com/r/en-US/ug973-vivado-release-notes-install-license/Running-the-Installer) before installation.
- I do not guarantee the normal operation of this scripts.
  - Not all the functionalities are tested. Connections via USB may not work.
  - My used toolkit version is `2024.1`. Different version may cause error.

## Installation
1. Register your ID on AMD's website, download (web) `installer.bin` from there and put it on the cloned repo folder.
  - Set its filename to `XILINX_INSTALLER` in `Dockerfile` when it differs.
  - Also change `TOOLS_VERSION` in `entrypoint.sh` if it's changed.
2. Create authentication token `wi_authentication_key` before making containers.
  - Make it by `sh your_downloaded_xilinx_web_installer.bin -- -b AuthTokenGen`.
3. Copy `~/.Xilinx/wi_authentication_key` into the folder same to `Dockerfile`.
4. Do `docker image build -t ubuntu22-vitis .`. It takes a while (> 1hr).

## Usage
1. `xhost +si:localuser:$(whoami)` to give X11 privillage from docker.
  - In wayland `xorg-xhost` package is needed.
2. Then run the container like below:
  - Notice: In example the folder in the host `~/vivado`, is the workdir `/work` in the container.
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
    # -e XILINXD_LICENSE_FILE=/work/dot_Xilinx/Xilinx.lic \   # Optional: If you have a license file
    # --mac-address="02:42:11:11:11:11" \  # Optional: To fix MAC addr of the container
    # --hostname="ubuntu22-docker" \  # Optional: To fix hostname of the container
    ubuntu22-vitis
```
3. Just call `vivado` or `vitis` in the container.

## Tips and Notes
- With this config `Vitis` and `Vivado` are installed. If you need only `Vivado` generate the config (`installer.bin -- -b ConfigGen`) by yourself and replace `install_config.txt`. Also to select devkit(s) of specific FPGA series change `Modules` option of `install_config.txt`.
- To use node-locked license, first to the container set (fix) the MAC addr and hostname, then issue the licence from AMD, and assign that file into `XILINXD_LICENSE_FILE` variable.
- 2nd run of vitis fails with blank window (can be a high-DPI problem?). In that case please restart the container.

## Changelog
- 2024/06/09
  - Ubuntu base image is Jammy (22), and I've replaced some packages
  - gosu is installed using apt.
- 2024/06/10
  - Now the vitis launches inside the container :)
- 2024/09/23
  - Coping with node-locked license