# Changelog

## Security hardening — CA key moved to encrypted drive

### What changed

Previously, the CA private key (`ca-key.pem`) was stored in `/var/lib/certs` alongside the CA certificate and Tailscale server cert. This directory lives on the unencrypted SD card. A thief who stole the hardware could extract `ca-key.pem` from the SD card and use it to mint a trusted mTLS client certificate, giving themselves authenticated access if the drive were ever decrypted or the server brought back online.

**The CA private key is now stored on the encrypted drive at `/mnt/immich_drive/secrets/ca-key.pem`.**

- `ca-cert.pem` remains in `/var/lib/certs` — Caddy needs it at startup to verify client certificates and it contains no secret material.
- `ca-key.pem` moves to `/mnt/immich_drive/secrets/` — it is only needed when issuing new client certificates and is now protected by drive encryption.
- `gen-mtls-certs` defaults updated: `--ca-path` has been replaced by `--ca-cert-path` (defaults to `/var/lib/certs`) and `--ca-key-path` (defaults to `/mnt/immich_drive/secrets`).

### Migrating an existing server

> [!IMPORTANT]
> The encrypted drive must be mounted before running these steps.

1. Move the CA private key to the encrypted drive:
   ```bash
   sudo mv /var/lib/certs/ca-key.pem /mnt/immich_drive/secrets/ca-key.pem
   ```

2. Rebuild to get the updated `gen-mtls-certs` script:
   ```bash
   sudo nixos-rebuild switch
   ```

3. Confirm Caddy still owns the certs directory (it does not need the CA key):
   ```bash
   sudo chown -R caddy:caddy /var/lib/certs
   sudo systemctl restart caddy
   ```

4. Verify Caddy started cleanly and mTLS still works with an existing client certificate:
   ```bash
   journalctl -eu caddy --since "1 min ago"
   ```

No client certificates need to be re-issued. The CA cert (`ca-cert.pem`) that Caddy uses for verification has not changed, so all previously issued client certs remain valid.
