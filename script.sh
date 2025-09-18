#!/bin/sh

#############
# VARIABLES	#
#############

# Complete the full path with the partition given
hard_drive="/dev/$1"

# Get the mountpoint of that partition
mountpoint=`lsblk | grep $1 | awk '{print $7}'`

# Obtain the drive's state, whether it is removable or not
#	0 -> unremovable
#	1 -> removable
is_removable=`lsblk | grep $1 | awk '{print $3}'`

# Detect if the partition is used to boot
detect_bootable_partition=`fdisk -l | grep $1 | awk '{print $6}'`

# Values needed to modify drive's configuration files later
file_system_type=`lsblk -f | grep $1 | awk '{print $2}'`
lvm_encrypted_name="partition_encrypted"

#############
# FUNCTIONS	#
#############

#
# This function will fully encrypt any partition/hard drive you tell.
#
encrypt_disk () {
	# Confirm if partition is mounted on the system to automatically umount it
	# '-n' flag tests if the length of the variable is nonzero
	# For more info run 'man test'
	if [ -n $mountpoint ]; then
		# Check whether or not the encryption of the partition is supported
		if [ $mountpoint = "/" ] || [ $mountpoint = "[SWAP]" ]; then
			echo "Sorry, $mountpoint encryption is not supported." ; exit
		elif [ $detect_bootable_partition = "EFI" ] || [ $detect_bootable_partition = "BIOS" ]; then
			echo "The partition containing the bootloader must not be encrypted" ; exit
		else
			umount $mountpoint
		fi
	else
		:
	fi

	# Commands needed to encrypt, providing the names stored in variables
	cryptsetup luksFormat $hard_drive
	cryptsetup -v luksOpen $hard_drive $lvm_encrypted_name
	mkfs.ext4 -L LuksPartition /dev/mapper/$lvm_encrypted_name
}

#
# In case you are protecting your main drive, we need to save these changes
# to the system, so the kernel mounts the partitions rightly at booting process
#
write2disk () {
	mount /dev/mapper/$lvm_encrypted_name $mountpoint 

	# Get the UUID of the encrypted drive
	uuid=`cryptsetup luksUUID $hard_drive`

	# Check if the 'crypttab' file exists
	# The configuration file of the encrypted volumes
	# For more info run 'man crypttab'
	if [ -f /etc/crypttab  ]; then
		:
	else
		touch /etc/crypttab
	fi

	# Write changes to it
	echo "$lvm_encrypted_name	UUID=$uuid	none	luks" >> /etc/crypttab 

	# Modify also 'fstab' to automatically mount the partition at each boot
	# Read scripts's documentation to comment the right line
	echo "################################
#                              #
# YOUR NEW ENCRYPTED PARTITION #
#                              #
################################
/dev/mapper/$lvm_encrypted_name	$mountpoint	$file_system_type	defaults,relatime	0	2" >> /etc/fstab

	nano /etc/fstab
}

#############
# LAUNCHING	#
#############

case $is_removable in
       0)
        encrypt_disk
        write2disk
        ;;
       1)
        encrypt_disk
        ;;
       *)
        ;;
esac

