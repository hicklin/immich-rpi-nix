if [ "$IMMICH_BACKUP_ESSENTIAL_ONLY" = "true" ]; then
    rustic backup \
    /mnt/immich_drive/immich_data/library \
    /mnt/immich_drive/immich_data/upload \
    /mnt/immich_drive/immich_data/profile \
    /mnt/immich_drive/immich_data/backups
else
    rustic backup /mnt/immich_drive/immich_data/
fi
