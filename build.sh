#!/usr/bin/env bash
###############################################################################
##
##       filename: build.sh
##    description:
##        created: 2025/08/01
##         author: ticktechman
##
###############################################################################

set -e

download_img() {
  wget -O alpine.qcow2 https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/cloud/nocloud_alpine-3.22.1-aarch64-uefi-cloudinit-r0.qcow2
  qemu-img convert -f qcow2 -O raw alpine.qcow2 alpine.img
  truncate -s 10G alpine.img
  fdisk ./alpine.img <<EOF
p
e
2


w
EOF
}

patch_img() {
  sudo losetup -fP ./alpine.img
  sleep 0.5
  local dev="$(losetup -l | grep ${PWD}/alpine.img | cut -f1 -d' ')"
  [[ ! -d 'efi' ]] && mkdir efi
  [[ ! -d 'linux' ]] && mkdir linux
  sudo mount "${dev}p1" efi/
  sudo mount "${dev}p2" linux/

  sudo cp -R patch/* linux/
  sudo umount efi linux
  sudo losetup -d "${dev}"
}

pack() {
  ./gen-seed.sh
  [[ -d alpine-img ]] || mkdir alpine-img
  mv alpine.img seed.iso alpine.json ./alpine-img/
  tar zcf alpine-img.tar.gz alpine-img
}

download_img
patch_img
pack
###############################################################################
