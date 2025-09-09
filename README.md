Please, before proceeding with the encryption, read the documentation carefully.

# Information

> [!IMPORTANT] 
> Some considerations to take in count;
> - First thing you must do is to backup whatever data you have on the drive you are going to encrypt. This feature will be added soon.
> 
> - Secondly,  be aware that neither `/` nor `[SWAP]` partitions encryption is not supported, since the system itself has to be mounted to run the system. On the other hand, when it comes to `[SWAP]`, the steps to disable its partition are different, and there would be to do it manually. 
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
>  | **Runlevel** |                        **Description**                       						|
> |:------------:|:--------------------------------------------------------------------	|
> |       0      |                The system can be powered off.                					|
> |       1      |               Single user mode; typically root.              						|
> |       2      |        Multiple user mode with no Network File System.       		|
> |       3      |           Multiple user mode without GUI, just CLI.          				|
> |       4      |                        User-definable.                        									|
> |       5      | Multiple user mode with GUI; standard in most Linux distros.	|
> |       6      |                            Reboot.                            										|
>
>  </div>
>  


  


