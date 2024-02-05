#!/bin/bash
#
# Create partition
#

TAR_SRC_PATH=download-src
CURRENT_DIR=${PWD}

DOTNET_IMG="dotnet.ext4"
DATA_IMG="data.ext4"
BACKUP_IMG="backup.ext4"
DOTNET_INSTALL_FOLDER="dotnet_installed"

if [[ ! -d "buildroot-2022.02/output/images" ]];
then
	mkdir -p "buildroot-2022.02/output/images"
fi

if [[ ! -d "buildroot-2022.02/output/images/$DOTNET_INSTALL_FOLDER" ]];
then
	mkdir -p "buildroot-2022.02/output/images/$DOTNET_INSTALL_FOLDER"

fi




cd buildroot-2022.02/output/images

if [[ -f "$DATA_IMG" ]];
then
	rm "$DATA_IMG"
fi

if [[ -f "$DOTNET_IMG" ]];
then
	rm "$DOTNET_IMG"
fi

if [[ -f "$BACKUP_IMG" ]];
then
	rm "$BACKUP_IMG"
fi

# data 256000 * 4096 = 1000M	
dd if=/dev/zero of=$DATA_IMG bs=4k count=256000 
mkfs.ext4 $DATA_IMG
e2label $DATA_IMG data
tune2fs -c0 -i0 $DATA_IMG

# dotnet 196608 * 4096 = 768
dd if=/dev/zero of=$DOTNET_IMG bs=4k count=196608  	
mkfs.ext4 $DOTNET_IMG
e2label $DOTNET_IMG dotnet
tune2fs -c0 -i0 $DOTNET_IMG

# rootfs 128000 * 4096 = 500M < 512
dd if=/dev/zero of=$BACKUP_IMG bs=4k count=128000 
mkfs.ext4 $BACKUP_IMG
e2label $BACKUP_IMG backup
tune2fs -c0 -i0 $BACKUP_IMG

echo Writting dotnet...

echo Mounting...
echo ghi | sudo -S mount $DOTNET_IMG $DOTNET_INSTALL_FOLDER

echo ghi | sudo -S mkdir $DOTNET_INSTALL_FOLDER/.dotnet
echo ghi | sudo -S mkdir $DOTNET_INSTALL_FOLDER/.vsdbg

echo ghi | sudo -S tar xvf ${TAR_SRC_PATH}/dotnet-sdk-8.0.100-linux-arm.tar.gz -C $DOTNET_INSTALL_FOLDER/.dotnet
sync
echo ghi | sudo -S tar xvf ${TAR_SRC_PATH}/vsdbg-linux-arm.tar.gz -C $DOTNET_INSTALL_FOLDER/.vsdbg
sync
echo ghi | sudo -S chmod +x $DOTNET_INSTALL_FOLDER/.vsdbg/vsdbg
sync
echo Umounting...
echo ghi | sudo -S  umount $DOTNET_INSTALL_FOLDER

cd $CURRENT_DIR

echo Done!
	
