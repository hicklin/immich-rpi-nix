# Configure backups

It is essential that we backup our assets. Our drive may fail, get damaged or stolen and we don't want this to result in the loss our precious memories.

The most resilient backups are cloud storage services. However, we want to ensure that our data is encrypted and only accessible by us. To achieve this we have two options; use a **trusted end-to-end encryption and zero-trust storage service** or **encrypt the data ourselves**.

If you are embarking on this project, you are likely a secure conscious individual and may already have [Proton Mail](https://proton.me/mail). The paid plan comes with 500 GB of Proton Drive which is an end-to-end encryption and zero-trust storage service. Unfortunately, Proton Drive do not currently provide a robust solution for Linux. If you are interested in trying to use this, read [Proton Drive Backups](../alternative-setups/4-proton-drive-backups.md).

We will use [`rustic`](https://rustic.cli.rs/docs/intro.html) to encrypt and archive our data on non-zero-thrust services like Backblaze, GCP, AWS, etc, achieving a similar security posture to Proton Drive. `rustic` is a fast and secure backup program. It encrypts and syncs our data to a remote location.

We need to backup the following essential directories from `/mnt/immich_drive/immich_data/`
- `library`: Used if storage templates are enabled
- `upload`: all original assets
- `profile`: user profiles
- `backups`: database backup

> [!TIP]
> You can configure the frequency and retention of database backups. For more information consult the [immich docs](https://docs.immich.app/administration/backup-and-restore#automatic-database-dumps).

Just uploading these directories will require immich to regenerate thumbs and encoded-videos during recovery. By default, both essential and generated data is backed up. This ensures a seedy and smooth recovery. If you wish to only backup essential files, set the `IMMICH_BACKUP_ESSENTIAL_ONLY` environment variable in `configuration.nix` to `"true"`. Remember to follow this up with `sudo nixos-rebuild switch`.

## 1. Setup a storage provider

Choose a cloud storage provider compatible with `rustic`. You can find a list of supported backends [here](https://rustic.cli.rs/docs/comparison-restic.html#supported-storage-backends). I recommend using [backblaze](https://www.backblaze.com/). It's a pay-as-you-go service with reasonable cost per TB and it is fully supported by `rustic`.

Follow the instructions by the could storage provider to setup a storage bucket and generate an application key.

## 2. Configure rustic

Rustic requires a `.toml` configuration file with credentials to access your storage service and repository. In this context, repository refers to the stored encrypted data. You can find the latest configuration file example for backblaze and other services [here](https://github.com/rustic-rs/rustic/blob/main/config/services/b2.toml). Create a copy of the relevant example in `/mnt/immich_drive/secrets` and update the values with information from your cloud storage provider.

> [!CAUTION]  
> The password in `[repository]` is what's used to encrypt/decrypt the backup data. **Do not loose this** otherwise you will not be able to access your backup data.

The contents of this config contains all the necessary information to access your private data. Hence, it's important to keep this secure. To do this, we will store this file in the `secrets` directory in the encrypted drive and link it in the required directory.

1. Create the dir for the rustic configuration.
   ```bash
   sudo install -d -m 755 -o ${USER} -g users /etc/rustic
   ```
2. Link the rustic configuration to the required location.
   ```bash
   ln -s /mnt/immich_drive/secrets/rustic.toml /etc/rustic/rustic.toml
   ```

## 3. Initialise the repository - One time

This step initialises the backup location (the cloud bucket) for rustic. We only need to run this once.

```bash
rustic init
```

## 4. Manual backup

The nix configuration provides a service for backing up data.

```bash
sudo systemctl start immich-backup
```

This service will run once and will encrypt and backup our data. You can check the logs for this service with:

```bash
journalctl -xeu immich-backup.service
```

To monitor the progress of the backup use `rustic repoinfo`.

## 5. Schedule backups

Our nix configuration schedules backups to start 60 minutes after boot and again every day. If you wish to modify this, you can amend `systemd.timers."immich-backup"` in `configuration.nix`.
