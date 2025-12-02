if [ "$IMMICH_BACKUP_ALL" = "true" ]; then
    rustic backup /mnt/immich_drive/immich_data/*
else
    rustic backup /mnt/immich_drive/immich_data/library/upload /mnt/immich_drive/immich_data/library/profile /mnt/immich_drive/immich_data/library/backups
fi
