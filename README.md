Please, before proceeding with the encryption, read the documentation carefully.

# Information

> [!IMPORTANT] 
> Some considerations to take in count;
> - First thing you must do is to backup whatever data you have on the drive you are going to encrypt. This feature will be added soon.
> 
> - Secondly,  be aware that neither `/` nor `[SWAP]` partitions encryption is supported, since the system itself has to be mounted to run the system. On the other hand, when it comes to `[SWAP]`, the steps to disable its partition are different, and there would be to do it manually. 
> 
> - Ensure you have the following dependencies:
>   - `nano`
>   - `fdisk`
>   - `cryptsetup` 
>
> - In order to use the script, you will need to change the run level of the system if you are going to encrypt the main drive of your computer. All tests tried have been executed in level **1**, where only root can be logged in, but level **3** might work as well. There's just to make sure the partition you are going to protect is not being used at the moment. To change the run level execute `telinit level`, where *level* can be one of the next options:
>
>  <div align="center">
>  
> | **Runlevel** |                        **Description**                      	|
> |:------------:|:------------------------------------------------------------:|
> |       0      |                The system can be powered off.                |
> |       1      |               Single user mode; typically root.              |
> |       2      |        Multiple user mode with no Network File System.       |
> |       3      |           Multiple user mode without GUI, just CLI.          |
> |       4      |                        User-definable.                       |
> |       5      | Multiple user mode with GUI; standard in most Linux distros.	|
> |       6      |                            Reboot.                           |
>
>  </div>
>  

&nbsp;

# Running the script
Before doing something ensure the script has execution permissions; `chmod 755 script.sh`. Once you are ready to go, execute it running `sudo ./script.sh` followed **ONLY** by the name of the partition. For example from the following output after running the `lsblk` command:

```bash
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 238,5G  0 disk 
├─nvme0n1p1 259:1    0   487M  0 part /boot/efi
├─nvme0n1p2 259:2    0 161,1G  0 part /
├─nvme0n1p3 259:3    0   1,9G  0 part [SWAP]
└─nvme0n1p4 259:4    0    75G  0 part /home
```

If I wanted to encrypt the `home` partition (which was the main purpose this script was made for), I'd have to pass just `nvme0n1p4` as the argument, resulting in the next command: `./script.sh nvme0n1p4`. From this moment, you will drive through the different steps.

## Making the changes persistent

> [!NOTE] 
> You can ignore this part of the docs whether you are encrypting a USB stick or whatever drive that's not the main one of your machine.

Modifying a main drive's partitions entails to mount them at each booting, then we'll need to tell the kernel to do so. That can be achieved by modifying the `fstab` file, after having done the same to `crypttab`.

### /etc/crypttab
As the crypttabs's manual says, it *contains descriptive information about encrypted devices*. That information follows the next structure, and it's essential to accomplish the mounting process:

```bash
<encrypted volume name>	<uuid>	none	luks
```

You won't have to worry about this step because the script will automatically write this data to the `crypttab` file.

### /etc/fstab
The `fstab` file is actually the one used by the kernel to mount the partitions before loading the operating system.

> [!WARNING] 
> Here comes the most critical part of the whole process, since if any bad information is written to the file, you won't be able to power on your computer.

`fstab` follows the next information structure, and as the same way with `crypttab`, it will be added automatically by the script.

```bash
<file system>	<mount point>	<type>	<options>	<dump>	<pass>
```

The only manual operation we have to make is commenting the line that establishes the mounting of the encrypted partition. Continuing with the example given before, if I went to encrypt the `home` partition then the next line would have to be commented by adding a **#** at the beginning:

```bash
...
UUID=6c8a0b1d-5abc-4801-a226-2c5fd26ca693	/home           ext4    defaults        0       2
...
```

With that, whole operation is finished.

&nbsp;

# Troubleshooting
After I encrypted my `home` folder I was chill thinking I wouldn't find out any problem, but nothing could be further from the truth. Next time I powered on my machine, I couldn't type on decrypting passphrase menu with my laptop's keyboard, and the only way to boot was running the OS through recovery mode.

After browsing the web for a while I realized that many people have been struggling with this trouble for [many years](https://bugs.launchpad.net/ubuntu/+source/plymouth/+bug/1386005?comments=all) and there's not been a solution yet, although some have managed to solve it:

 - [Enter password on encrypted drive, keyboard not working](https://forums.linuxmint.com/viewtopic.php?t=211313&sid=41c9b0cc4d0f225260d974b21e3544fc)
 - [Full Disk Encryption Passphrase at Boot: Keyboard not working](https://askubuntu.com/questions/613241/full-disk-encryption-passphrase-at-boot-keyboard-not-working)

The most common answer to overcome this I found is to, apparently, using an external keyboard in case you are using a laptop. I haven't been able to try it so I must be quiet.

