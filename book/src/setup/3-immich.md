# Immich setup

We will finish setting up immich, install the companion app on our phone and access the server from a web browser. For now, we will only be able to access immich from devices on the same network. We will enable remote access in [step 5](./5-remote-access.md).

## Raspberry Pi

Immich is already installed and configured on the RPi, however it requires a secrets file to operate. Follow these one-time steps to set this up.

1. Create a mount location for the external drive.
   ```bash
   sudo install -d -m 755 -o ${USER} -g users /mnt/immich_drive
   ```
2. Identify the path to the drive with `lsblk`. The path is `/dev/<name>` where `<name>` is the first column of `lsblk`. E.g. `/dev/sda` or `/dev/sda1` if partitioned.
3. Decrypt and mount the external drive.
   ```bash
   immich-server --immich-drive /dev/sda
   ```
4. Create a `secrets` folder in the encrypted drive.
   ```bash
   install -d -m 755 -o ${USER} -g users /mnt/immich_drive/secrets
   ```
5. Copy the example secrets file to your encrypted drive.
   ```bash
   cp ~/immich-rpi-nix/immich-secrets.example /mnt/immich_drive/secrets/immich-secrets
   ```
6. **Change the `DB_PASSWORD` value** in `/mnt/immich_drive/secrets/immich-secrets`.
   > [!CAUTION]
   > Securely store the `DB_PASSWORD`. This is necessary to recover the database which is essential to make sense of our backup.
7. Create the directory for immich postgres database in the encrypted drive with the correct permissions.
   ```bash
   sudo install -d -m 750 -o postgres -g users /mnt/immich_drive/postgres
   ```
8. Create the directory for immich data in the encrypted drive with the correct permissions.
   ```bash
   sudo install -d -m 755 -o immich -g users /mnt/immich_drive/immich_data
   ```
9.  Start immich
      ```bash
      immich-server --start --no-decryption
      ```
10. You can use `journalctl -u immich-server -f` to follow the logs from the immich service.

## Phone app

1. Download the immich app from [https://immich.app/](https://immich.app/).
2. Set the server URL to `http://immich.local:2283`. If you have issues using `immich.local`, identify and use the RPi IP with `sudo arp-scan -l` or from the RPi with `ip addr show`.
3. For more information about using the app, consult the [immich documentation](https://docs.immich.app/overview/quick-start#try-the-mobile-app).

## Web app

In your web browser type `http://immich.local:2283`. If you have issues using `immich.local`, identify and use the RPi IP with `sudo arp-scan -l` or from the RPi with `ip addr show`.

## Immich initialisation

Upon first access, you will be prompted to setup the admin user.

> [!CAUTION]
> Securely store the admin credentials.
