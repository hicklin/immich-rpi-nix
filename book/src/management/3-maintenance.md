# Maintenance 

You will need to perform some minimal maintenance procedures to ensure that the system continues to operate securely.

## OS updates

For security purposes, it is important to use up-to-date software. To update NixOS, first update the nix channel, providing updated packages:

```bash
sudo --nix-channel --update
```

The rebuild the system with:

```bash
sudo nixos-rebuild switch
```

> [!TIP]
> If you experience an issue after the update, you can always roll back to a previous build with `nixos-rebuild --rollback switch`. You can read more about `nixos-rebuild` commands [here](https://nixos.wiki/wiki/Nixos-rebuild).

## Check backup logs

Periodically check the backup logs to ensure that the backup application is still working. Run the following command and check that the last log is successful and within 24 hours.

```bash
journalctl -eu immich-backup.service
```
