# On boot

Since we have an encrypted drive, and since we do not want the password to exist on the unencrypted OS memory, we have to manually input it after boot. This project provides a helper script as part of the nix configuration called `immich-server`. After boot call

```bash
immich-server --start --immich-drive /dev/sda
```

This script will first ask you for your **user password** then ask you for the **immich drive decryption password**.

> [!NOTE]
> Your drive may be in a different location than `/dev/sda`. 

> [!NOTE]
> If you opted out of an encrypted immich drive, you can enable immich to start on boot by removing `systemd.xxx.xxx.wantedBy = lib.mkForce [];` lines in `configuration.nix`. Remember to run `sudo nixos-rebuild switch` after commenting it out. You may still need to automate mounting the drive to `/mnt/immich_drive`.
