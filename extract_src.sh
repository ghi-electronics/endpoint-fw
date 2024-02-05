#!/bin/sh

BR_VER=buildroot-2022.02
OVERLAY_PATH=${BR_VER}/board/stmicroelectronics/ep/overlay
CURRENT_DIR=${PWD}
TAR_SRC_PATH=download-src

mkdir -p ${OVERLAY_PATH}/root/.epnet
mkdir -p ${OVERLAY_PATH}/root/.epdata
mkdir -p ${OVERLAY_PATH}/usr/lib/python3.10/site-packages

echo tar source...
tar xvf ${TAR_SRC_PATH}/${BR_VER}.tar.bz2
tar xvf ${TAR_SRC_PATH}/linux-5.13.tar.xz -C custom-src/
tar xvf ${TAR_SRC_PATH}/rtl8188eu-c4908ca4caf861d858c4d9e8452a2ad5c88cf2ba.tar.gz -C custom-src/
tar xvf ${TAR_SRC_PATH}/u-boot-2021.10.tar.bz2 -C custom-src/


tar xvf ${TAR_SRC_PATH}/ptvsd.tar -C ${OVERLAY_PATH}/usr/lib/python3.10/site-packages
tar xvf ${TAR_SRC_PATH}/ptvsd-4.3.2.dist-info.tar -C ${OVERLAY_PATH}/usr/lib/python3.10/site-packages

# delete all py source file, only keep pyc
cd ${OVERLAY_PATH}/usr/lib/python3.10/site-packages
find . -name '*.py' -delete

cd ${CURRENT_DIR}

echo Waiting for sync...
sync

echo Done!


