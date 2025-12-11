# Maintenance 

You will need to perform some minimal maintenance procedures to ensure that the system continues to operate securely.

## OS updates

For security purposes, it is important to maintain up-to-date software. To update packages in NixOS run

```bash
sudo nixos-rebuild switch --upgrade
```

Alternatively, we can setup automatic updates by adding the following snippet to our `configuration.nix`.

```nix
system.autoUpgrade = {
  enable = true;
  allowReboot = false;  # Setting to false otherwise we'll need to manually start the server.
  dates = "02:00";
  randomizedDelaySec = "45min";
};
```

> [!IMPORTANT]
> This may cause failures when you least expect it. If you experience an issue after an update, you can roll back to a previous build with `nixos-rebuild --rollback switch`. You can read more about `nixos-rebuild` commands [here](https://nixos.wiki/wiki/Nixos-rebuild).

## Check backup logs

Periodically check the backup logs to ensure that the backup application is still working. Run the following command and check that the last log is successful and within 24 hours.

```bash
journalctl -eu immich-backup.service
```
