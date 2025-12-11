# Harden RPi with SSH keys

In this chapter we will harden the Raspberry Pi access through the use of SSH keys and disabling password login. This ensures that only devices with authorised SSH keys can access the RPi.

## Setup SSH keys

If you do not have SSH key generated for your machine, generate them with:

```bash
ssh-keygen
```

Copy these keys to the RPi with

```bash
ssh-copy-id -i <path to key>.pub admin@immich.local
```

Now you can log into the RPi without needing typing the password.

> [!TIP]
> If you have issues using `ssh-copy-id` you can manually copy your public SSH key to the `~/.ssh/authorized_keys` path on the RPi.

## Disabling password authentication

Locate and uncomment this code in `configuration.nix`.

```nix
  services.openssh = {
    # Disables remote password authentication.
    settings.PasswordAuthentication = false;
    # Disables keyboard-interactive authentication.
    settings.KbdInteractiveAuthentication = false;
  };
```

> [!CAUTION]
> Once password authentication is disabled, only devices with the matching private keys will be able to access the RPi. Make sure to save authorised SSH keys in your password manager in case those devices fail.