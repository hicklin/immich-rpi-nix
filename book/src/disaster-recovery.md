# Disaster recovery

This chapter covers recovering your immich setup from backups. These instructions cover two distinct situations.
- **Recovery From Cloud Storage**: Setting up the external drive, RPi and getting data backed-up on cloud storage.
- **Recovery From External Drive**: The external drive data is intact and can be used as is. Setting up of RPi.

## Recovery From Cloud Storage

1. Encrypt the new drive following [setup step 1](./setup/1-encrypt-drive.md).
2. Setup the RPi following [setup step 2](./setup/2-raspberry-pi.md).
3. Setup immich following [setup step 3, Raspberry Pi](./setup/3-immich.md#raspberry-pi) up to and including step 8.
4. Stop the immich-backup timer from triggering.
   ```bash
   sudo systemctl stop immich-backup.timer
   ```
5. Configure `rustic` following [setup step 4](./setup/4-backups.md), up to and including step 2.
6. Recover the data from the cloud. **Note** You can add `--dry-run` to see what would be restored.
   ```
   rustic restore latest /mnt/immich_drive/immich_data
   ```
7. Restore the database from the latest backup in `immich_data/backups`
   1. Start postgres, the database
   ```bash
   sudo systemctl start postgresql
   ```
   2. restore backup
   ```bash
   gunzip -c /mnt/immich_drive/immich_data/backups/<latest dump> | sudo -u postgres psql -d postgres
   ```
   > [!IMPORTANT]
   > If your database backups where created from a database with a user other than `immich`, such as the default docker immich configuration where `DB_DATABASE_NAME=postgres`, grant equivalent permissions to `immich` as that user with:
   > ```bash
   > sudo -u postgres psql -c "GRANT <DB_DATABASE_NAME of old DB> TO immich;"
   > ```
   3. Ensure correct permissions to immich_data
   ```bash
   sudo chown -R immich:users /mnt/immich_drive/immich_data
   ```
8. Start immich
   ```bash
   immich-server --start --no-decryption
   ```
9.  Access the server and confirm that the backup is complete.
    > [!NOTE]
    > If you only backed up essential files, your RPi might need some processing time.
10. Restart the immich-backup timer
    ```
    sudo systemctl start immich-backup.timer
    ```
11. Run the following command and follow the URL output to register the RPi on tailscale.
    ```bash
    sudo tailscale up
    ```

## Recovery From External Drive

These instruction are for when the external drive already contains all the immich data of a previous server instance.

> [!CAUTION]
> For this to work, the old and new postgres versions will need to match. There may be other nuances that might cause this to fail. If it does, you can always use the data in the drive to backup the database. You can follow the [Migration Processing Off RPi](./alternative-setups/1-migration-processing-off-rpi.md) procedure starting from step 8.

1. Setup the RPi following [setup step 2](./setup/2-raspberry-pi.md).
2. Setup immich following [setup step 3, Raspberry Pi](./setup/3-immich.md#raspberry-pi) up to and including step 3.
3. Start immich
   ```bash
   immich-server --start --no-decryption
   ```
4. Access the server and confirm that all the photos are there.
5. Run the following command and follow the URL output to register the RPi on tailscale.
    ```bash
    sudo tailscale up
    ```
