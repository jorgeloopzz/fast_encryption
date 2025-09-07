#!/bin/sh

# Variables
hard_drive="/dev/$1"
mountpoint=`lsblk | grep $1 | awk '{print $7}'`
is_removable=`lsblk | grep $1 | awk '{print $5}'`	# 0 means 'Not removable'
lvm_encrypted_name="partition_encrypted"

encrypt_disk () {
	if [ -n $mountpoint ]; then

		# Check whether or not the encryption of the partition is supported
		if [ $mountpoint = "/" ] || [ $mountpoint = "[SWAP]" ]; then
			echo "Sorry, $mountpoint encryption is not supported."
		fi

		# umount $mountpoint
		echo "The $mountpoint is not empty"
	else
		:
	fi

	# cryptsetup luksFormat $hard_drive
	# cryptsetup -v luksOpen $hard_drive $lvm_encrypted_name
	# mkfs.ext4 -L LuksPartition /dev/mapper/$lvm_encrypted_name
	echo "Hard drive already encrypted"
}

write2disk () {
	uuid=`cryptsetup luksUUID $hard_drive`
	echo "$uuid"
}

# encrypt_disk

write2disk

