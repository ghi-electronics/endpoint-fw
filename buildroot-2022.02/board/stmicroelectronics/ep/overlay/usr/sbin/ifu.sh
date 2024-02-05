#!/bin/sh
#
# IFU
#

SRC_FOLDER="$2"
IFU_MOUNT_FOLDER="/root/ifu"

switch_extlinux() {
	if [[ ! -d $IFU_MOUNT_FOLDER ]] 
	then
		mkdir $IFU_MOUNT_FOLDER
	fi 
	
	echo "Config boot..."
	boot="$(cat /boot/extlinux/extlinux.conf)"
	
	if [[ "$boot" == *"mmcblk1"* ]];
	then
		if [[ "$boot" == *"p4"* ]];
		then
			mount /dev/mmcblk1p5 $IFU_MOUNT_FOLDER
			rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk1p5.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			
			
			
		else
			mount /dev/mmcblk1p4 $IFU_MOUNT_FOLDER
			rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk1p4.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		
		fi
	
	else
		if [[ "$boot" == *"p4"* ]];
		then
			mount /dev/mmcblk2p5 $IFU_MOUNT_FOLDER
			rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk2p5.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		else
			mount /dev/mmcblk2p4 $IFU_MOUNT_FOLDER
			rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk2p4.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		
		fi
	
	fi
	
	#for file_s9 in /etc/init.d/S9*; do cp "$file_s9" "${IFU_MOUNT_FOLDER}/etc/init.d/";done
	if [[ -f "/etc/init.d/S90custom" ]]; then
		cp "/etc/init.d/S90custom" "${IFU_MOUNT_FOLDER}/etc/init.d/"
	fi
	
	# Disable boot from current partion.
	rm /boot/extlinux/extlinux.conf
	
	sync

	umount $IFU_MOUNT_FOLDER
	rm -r $IFU_MOUNT_FOLDER	
}

switch_extlinux_sd_to_emmc() {
	# Change extlinux. SD to EMMC always use mmcblk2p4
	if [ ! -d $IFU_MOUNT_FOLDER ] 
	then
		mkdir $IFU_MOUNT_FOLDER
	fi 
	
	mount /dev/mmcblk2p4 $IFU_MOUNT_FOLDER
	rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
	cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk2p4.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
	
	sync

	umount $IFU_MOUNT_FOLDER
	rm -r $IFU_MOUNT_FOLDER
	
	sync

}

switch_extlinux_emmc_to_sd() {
	# Change extlinux. 
	boot="$(cat /boot/extlinux/extlinux.conf)"
	
	if [ ! -d $IFU_MOUNT_FOLDER ] 
	then
		mkdir $IFU_MOUNT_FOLDER
	fi 
	
	
	if [[ "$boot" == *"p4"* ]];
	then
		mount /dev/mmcblk1p4 $IFU_MOUNT_FOLDER
		rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk1p4.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
	else
		mount /dev/mmcblk1p5 $IFU_MOUNT_FOLDER
		rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk1p5.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
		
	fi
			
	sync

	umount $IFU_MOUNT_FOLDER
	rm -r $IFU_MOUNT_FOLDER
	
	sync

}

update_all_sd2emmc() {	
	echo "All data will be deleted."
	echo "New firmware from SDCard will be cloned to eMMC."
	
	
	
	echo Erasing....
	sgdisk -og /dev/mmcblk2 
	#sgdisk -e /dev/mmcblk1
	#sgdisk -R=/dev/mmcblk2 /dev/mmcblk1
	#sgdisk -G /dev/mmcblk2
        sync
	
	sgdisk --resize-table=128 -a 1 \
	-n 1:34:1057          -c 1:fsbl1 \
	-n 2:1058:2081          -c 2:fsbl2 \
	-n 3:2082:10273          -c 3:uboot \
	-n 4:10274:1058849          -c 4:rootfs \
	-n 5:1058850:2107425        -c 5:backup \
	-n 6:2107426:4204577        -c 6:dotnet \
	-n 7:4204578:              -c 7:data \
	-p /dev/mmcblk2

	sync
        sgdisk -A 4:set:2 /dev/mmcblk2
	
	yes y | mkfs -t ext4 /dev/mmcblk2p4

        sync
	yes y | mkfs -t ext4 /dev/mmcblk2p5

        sync
	yes y | mkfs -t ext4 /dev/mmcblk2p6

        sync
	yes y | mkfs -t ext4 /dev/mmcblk2p7
	
	echo Installing bootloader....
	
	dd if=/dev/mmcblk1p1 of=/dev/mmcblk2p1 bs=512
	dd if=/dev/mmcblk1p2  of=/dev/mmcblk2p2 bs=512
	dd if=/dev/mmcblk1p3 of=/dev/mmcblk2p3 bs=512
	echo 0 > /sys/block/mmcblk2boot0/force_ro
	dd if=/dev/mmcblk1p1 of=/dev/mmcblk2boot0 bs=512
	echo 1 > /sys/block/mmcblk2boot0/force_ro

	echo 0 > /sys/block/mmcblk2boot1/force_ro
	dd if=/dev/mmcblk1p1 of=/dev/mmcblk2boot1 bs=512
	echo 1 > /sys/block/mmcblk2boot1/force_ro
        
        mmc bootpart enable 1 1 /dev/mmcblk2

        sync
	
	echo Done installing bootloader!
			
	echo Installing dotnet....
	umount /root/.epnet 
	sync
	
	dd if=/dev/mmcblk1p6 of=/dev/mmcblk2p6 bs=1M
	sync
	
	mount /dev/mmcblk1p6 /root/.epnet
	echo Done installing dotnet!
	sync
	
	sync
	echo Installing firmware....
	# Us backup partition to program emmc
	dd if=/dev/mmcblk1p5 of=/dev/mmcblk2p4 bs=1M
	echo Done installing rootfs!
	sync		
		
	switch_extlinux_sd_to_emmc
	
	echo "Done updating."
	
		
}

update_uboot() {
	boot="$(cat /boot/extlinux/extlinux.conf)"
	if [[ ! -f $SRC_FOLDER/ubootspl.ghi || ! -f $SRC_FOLDER/uboot.ghi ]] ;
	then
		echo "Error: Could not find needed files."
		return
	else
		value="$(lsblk | grep 'mmcblk2')"
		
		if [[ "$boot" == *"mmcblk1"* ]];
		then
			value="$(lsblk | grep 'mmcblk1')"
		fi
		
		
		if [[ "$value" == *"p1"* && "$value" == *"p2"* && "$value" == *"p3"* && "$value" == *"p4"* && "$value" == *"p5"* && "$value" == *"p6"* && "$value" == *"p7"* ]];			
		then
			echo "Updating bootloader...."
			
			dd if=$SRC_FOLDER/ubootspl.ghi of=/dev/mmcblk2p1 bs=512
			dd if=$SRC_FOLDER/ubootspl.ghi of=/dev/mmcblk2p2 bs=512
			dd if=$SRC_FOLDER/uboot.ghi of=/dev/mmcblk2p3 bs=512
			echo 0 > /sys/block/mmcblk2boot0/force_ro
			dd if=$SRC_FOLDER/ubootspl.ghi of=/dev/mmcblk2boot0 bs=512
			echo 1 > /sys/block/mmcblk2boot0/force_ro

			echo 0 > /sys/block/mmcblk2boot1/force_ro
			dd if=$SRC_FOLDER/ubootspl.ghi of=/dev/mmcblk2boot1 bs=512
			echo 1 > /sys/block/mmcblk2boot1/force_ro
			
			sync

			echo "Done updating."
		else
			echo "Error: The location map needs to be updated."
		fi
	fi
	
}

update_firmware() {
	boot="$(cat /boot/extlinux/extlinux.conf)"
	if [[ ! -f $SRC_FOLDER/rootfs.ghi ]] ;
	then
		echo "Error: Could not find needed files."
		return
	else
	
		value="$(lsblk | grep 'mmcblk2')"
		
		if [[ "$boot" == *"mmcblk1"* ]];
		then
			value="$(lsblk | grep 'mmcblk1')"
		fi
		
		if [[ "$value" == *"p1"* && "$value" == *"p2"* && "$value" == *"p3"* && "$value" == *"p4"* && "$value" == *"p5"* && "$value" == *"p6"* && "$value" == *"p7"* ]]; 			
		then
			echo "Updating firmware..."
			if [[ "$boot" == *"mmcblk1"* ]];
			then
				if [[ "$boot" == *"p4"* ]];
				then
					dd if=$SRC_FOLDER/rootfs.ghi of=/dev/mmcblk1p5 bs=1M
					sync
					sgdisk -A 5:set:2 /dev/mmcblk1
				else
					dd if=$SRC_FOLDER/rootfs.ghi of=/dev/mmcblk1p4 bs=1M
					sync
					sgdisk -A 4:set:2 /dev/mmcblk1
				fi
			
			else
				if [[ "$boot" == *"p4"* ]];
				then
					dd if=$SRC_FOLDER/rootfs.ghi of=/dev/mmcblk2p5 bs=1M
					sync
					sgdisk -A 5:set:2 /dev/mmcblk2
				else
					dd if=$SRC_FOLDER/rootfs.ghi of=/dev/mmcblk2p4 bs=1M
					sync
					sgdisk -A 4:set:2 /dev/mmcblk2
				fi
			
			
			fi
			
			sync
			
			switch_extlinux

			echo "Done updating."
		else
			echo "Error: The location map needs to be updated."
		fi
	fi
}

update_dotnet() {
	boot="$(cat /boot/extlinux/extlinux.conf)"
	if [[ ! -f $SRC_FOLDER/dotnet.ghi ]] ;
	then
		echo "Error: Could not find needed files."
		return
	else
	

		echo "Updating donet..."
		if [[ "$boot" == *"mmcblk1"* ]];
		then
			value="$(lsblk | grep 'mmcblk1')"
			
			if [[ "$value" == *"mmcblk1p1"* && "$value" == *"mmcblk1p2"* && "$value" == *"mmcblk1p3"* && "$value" == *"mmcblk1p4"* && "$value" == *"mmcblk1p5"* && "$value" == *"mmcblk1p6"* && "$value" == *"mmcblk1p7"* ]]; then
			
				dd if=$SRC_FOLDER/dotnet.ghi of=/dev/mmcblk1p6 bs=1M
				sync
				echo "Done updating."
			else
				echo "Error: The location map needs to be updated."
			fi
		else
			value="$(lsblk | grep 'mmcblk2')"
			if [[ "$value" == *"mmcblk2p1"* && "$value" == *"mmcblk2p2"* && "$value" == *"mmcblk2p3"* && "$value" == *"mmcblk2p4"* && "$value" == *"mmcblk2p5"* && "$value" == *"mmcblk2p6"* && "$value" == *"mmcblk2p7"* ]]; then
				dd if=$SRC_FOLDER/dotnet.ghi of=/dev/mmcblk2p6 bs=1M
				sync
				echo "Done updating."
			else
				echo "Error: The location map needs to be updated."
			fi
		fi
		
		
			
	fi

}

update_dotnet_from_sdimage_to_emmc() {

	value="$(lsblk | grep 'mmcblk2')"
	boot="$(cat /boot/extlinux/extlinux.conf)"
	value2="$(lsblk | grep 'mmcblk1')"
	if [[ "$value2" == *"mmcblk1p1"* && "$value2" == *"mmcblk1p2"* && "$value2" == *"mmcblk1p3"* && "$value2" == *"mmcblk1p4"* && "$value2" == *"mmcblk1p5"* && "$value2" == *"mmcblk1p6"* && "$value2" == *"mmcblk1p7"* ]]; then
	
		if [[ "$value" == *"mmcblk2p1"* && "$value" == *"mmcblk2p2"* && "$value" == *"mmcblk2p3"* && "$value" == *"mmcblk2p4"* && "$value" == *"mmcblk2p5"* && "$value" == *"mmcblk2p6"* && "$value" == *"mmcblk2p7"* ]]; then
			
			echo "Updating dotnet from sd image to emmc..."
									
			yes y | mkfs -t ext4 /dev/mmcblk2p6
			sync
			
			dd if=/dev/mmcblk1p6 of=/dev/mmcblk2p6 bs=1M
			sync
						
			echo "Done updating."
			
		else
			echo "Error: The location map needs to be updated."
			
		fi
	else
		echo "Error: SD boot image not found."
	fi

}

update_firmware_from_sdimage_to_emmc() {
	value="$(lsblk | grep 'mmcblk2')"	
	boot="$(cat /boot/extlinux/extlinux.conf)"
	value2="$(lsblk | grep 'mmcblk1')"
	if [[ "$value2" == *"mmcblk1p1"* && "$value2" == *"mmcblk1p2"* && "$value2" == *"mmcblk1p3"* && "$value2" == *"mmcblk1p4"* && "$value2" == *"mmcblk1p5"* && "$value2" == *"mmcblk1p6"* && "$value2" == *"mmcblk1p7"* ]]; then
	
		if [[ "$value" == *"mmcblk2p1"* && "$value" == *"mmcblk2p2"* && "$value" == *"mmcblk2p3"* && "$value" == *"mmcblk2p4"* && "$value" == *"mmcblk2p5"* && "$value" == *"mmcblk2p6"* && "$value" == *"mmcblk2p7"* ]]; then
			
			echo "Updating frimware from sd image to emmc..."
						
			if [ ! -d $IFU_MOUNT_FOLDER ] 
			then
				mkdir $IFU_MOUNT_FOLDER
			fi
			
			if [[ "$boot" == *"p4"* ]]; then 
				sync
				sgdisk -A 5:set:2 /dev/mmcblk2
				
				yes y | mkfs -t ext4 /dev/mmcblk2p5
				sync
				dd if=/dev/mmcblk1p5 of=/dev/mmcblk2p5 bs=1M
				sync
				
				mount /dev/mmcblk2p5 $IFU_MOUNT_FOLDER
				rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
				cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk2p5.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			
			else
				sync
				sgdisk -A 4:set:2 /dev/mmcblk2
				
				yes y | mkfs -t ext4 /dev/mmcblk2p4
				
				sync
				dd if=/dev/mmcblk1p5 of=/dev/mmcblk2p4 bs=1M
				sync
				
				mount /dev/mmcblk2p4 $IFU_MOUNT_FOLDER
				rm $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
				cp $IFU_MOUNT_FOLDER/boot/extlinux/mmcblk2p4.conf $IFU_MOUNT_FOLDER/boot/extlinux/extlinux.conf
			
			fi
							
			sync

			umount $IFU_MOUNT_FOLDER
			rm -r $IFU_MOUNT_FOLDER
			
			# Disable boot from current partion.
			rm /boot/extlinux/extlinux.conf
			
			sync
			
			echo "Done updating."
			
		else
			echo "Error: The location map needs to be updated."
			
		fi
	else
		echo "Error: SD boot image not found."
	fi

}

update_all_emmc2sd() {	
	echo "All data will be deleted."
	echo "New firmware from eMMC will be cloned to SDCard."
	
	
	
	echo Erasing....
	sgdisk -og /dev/mmcblk1 

        sync
	
	sgdisk --resize-table=128 -a 1 \
	-n 1:34:1057          -c 1:fsbl1 \
	-n 2:1058:2081          -c 2:fsbl2 \
	-n 3:2082:10273          -c 3:uboot \
	-n 4:10274:1058849          -c 4:rootfs \
	-n 5:1058850:2107425        -c 5:backup \
	-n 6:2107426:4204577        -c 6:dotnet \
	-n 7:4204578:              -c 7:data \
	-p /dev/mmcblk1

	sync
        sgdisk -A 4:set:2 /dev/mmcblk1
	
	yes y | mkfs -t ext4 /dev/mmcblk1p4

        sync
	yes y | mkfs -t ext4 /dev/mmcblk1p5

        sync
	yes y | mkfs -t ext4 /dev/mmcblk1p6

        sync
	yes y | mkfs -t ext4 /dev/mmcblk1p7
	
	echo Installing bootloader....
	
	dd if=/dev/mmcblk2p1 of=/dev/mmcblk1p1 bs=512
	dd if=/dev/mmcblk2p2  of=/dev/mmcblk1p2 bs=512
	dd if=/dev/mmcblk2p3 of=/dev/mmcblk1p3 bs=512	        

        sync
	
	echo Done installing bootloader!
	
	sync
	echo Installing firmware....
	# Us backup partition to program emmc		
	dd if=/dev/mmcblk2p4 of=/dev/mmcblk1p4 bs=1M
	sync
	
	dd if=/dev/mmcblk2p5 of=/dev/mmcblk1p5 bs=1M
	sync
	echo Done installing rootfs!
	
	
	echo Installing dotnet....
	dd if=/dev/mmcblk1p6 of=/dev/mmcblk2p6 bs=1M
	echo Done installing dotnet!
	sync		
		
	switch_extlinux_emmc_to_sd
	
	echo "Done updating."
	
		
}

case "$1" in
	"0") 
		update_all_sd2emmc
	;;
	"1") 
		update_firmware
	;;
	"2") 
		update_uboot
	;;
	"3") 
		update_dotnet
		
	;;
	"4") 
		update_firmware_from_sdimage_to_emmc
		
	;;
	"5") 
		update_dotnet_from_sdimage_to_emmc
		
	;;
	"6") 
		update_all_emmc2sd
		
	;;
	*)
		echo "Argument is 0: Update SD to EMMC. 1: Update firmware. 2: Update Bootloader"
	;;
esac;
	

