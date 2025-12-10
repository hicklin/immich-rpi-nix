# Encrypt external drive

We encrypt the external drive to stop anyone gaining physical access to our drive from being able to see all our media assets. If this is not a concern, you can skip this step. I would encourage you to listen to [Darknet Dairies episode #163: Ola](https://open.spotify.com/episode/7K7NN1U7J2M6DOlDvKnbMq?si=dfbd5c4a83ec4830) before choosing to do so.

We need to create a **LUKS encrypted drive** with an **ext4 file system**. On Linux, we can use the file manager GUI tools to create this encrypted drive.

If you prefer using the terminal or are using the Windows Subsystem for Linux (WSL2), continue reading the command line instructions below. If you are running from the Windows Subsystem for Linux (WSL2), there may be some preamble to get things started. You can read more about this [here](https://learn.microsoft.com/en-us/windows/wsl/install).

> [!CAUTION]
> Securely store the encryption password. If you loose it you will loose access to all the files stored in this drive.

## Command Line Encryption

1. Identify the path to your drive, similar to `/dev/sdc`.
   - You use `lsblk` to list all the available drives and their path.
2. Use `cryptsetup` to encrypt the drive
   ```
   sudo cryptsetup luksFormat <drive path> --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random
   ```
3. Plug and decrypt the drive
   ```
   sudo cryptsetup open <drive path> immich_drive
   ```
4. Create the file system
   ```
   sudo mkfs.ext4 /dev/mapper/immich_drive
   ```

## Command Line Decryption

1. Plug in the drive and identify it's path, similar to above.
2. Decrypt the drive
   ```
   sudo cryptsetup open <drive path> immich_drive
   ```
3. Mount the drive
   ```
   sudo mount /dev/mapper/immich_drive /mnt/immich_drive
   ```
