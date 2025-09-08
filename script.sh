#!/bin/sh

# Variables
hard_drive="/dev/$1"
mountpoint=`lsblk | grep $1 | awk '{print $7}'`
is_removable=`lsblk | grep $1 | awk '{print $3}'`	# 0 means 'Not removable'
detect_bootable_partition=`fdisk -l | grep $1 | awk '{print $6}'`
lvm_encrypted_name="partition_encrypted"

encrypt_disk () {
	if [ -n $mountpoint ]; then

		# Check whether or not the encryption of the partition is supported
		if [ $mountpoint = "/" ] || [ $mountpoint = "[SWAP]" ]; then
			echo "Sorry, $mountpoint encryption is not supported." ; exit
		elif [ $detect_bootable_partition = "EFI" ] || [ $detect_bootable_partition = "BIOS" ]; then
			echo "The partition containing the bootloader must not be encrypted" ; exit
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

	mount /dev/mapper/$lvm_encrypted_name $mountpoint 

	# Check if the 'crypttab' file exists
	if [ -f /etc/crypttab  ]; then
		:
	else
		touch /etc/crypttab
	fi

	# Write changes to the encrypted volumes configuration file
	# For more info run 'man crypttab'
	echo "$lvm_encrypted_name	$uuid	none	luks" >> /etc/crypttab 

	# Write changes to 'fstab' to automatically mount the partition
	# Read documentation to comment the right line
	echo "
################################
#                              #
# YOUR NEW ENCRYPTED PARTITION #
#                              #
################################

/dev/mapper/$lvm_encrypted_name	$mountpoint	ext4	defaults,relatime	0	2
	" >> /etc/crypttab

	nano /etc/fstab
	
}

# encrypt_disk

write2disk

