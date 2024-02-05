#!/bin/sh

BR_VER=buildroot-2022.02
OVERLAY_PATH=${BR_VER}/board/stmicroelectronics/ep/overlay
CURRENT_DIR=${PWD}
TAR_SRC_PATH=~/gos/Desktop-window/tar-source

echo Waiting for sync...
sync

echo Overwrite custom source...
cp -r overwrite-src/linux-5.13/. custom-src/linux-5.13
cp -r overwrite-src/u-boot-2021.10/. custom-src/u-boot-2021.10

echo Waiting for sync...
sync

echo Done!


