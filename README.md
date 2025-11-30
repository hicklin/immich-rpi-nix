# immich-rpi-server
> A NixOS based Immich server on Raspberry Pi

This project aims to provide a cheap and simple way to set up and run an [Immich]() instance, empowering you to move away from BigTech without needing a computer degree. Having said that, you will be running your own server which will require understanding of some basic concepts. I attempt to provide sufficient documentation and explanations to help you on your way to regain sovereignty over your personal data.

The specific setup descried protects against the following treats.
- Remote internet access of server and data: Requires small overhead with [[#OS updates]].
- Access from local network: Requires setting strong passwords.
- Physical access to external storage and RPi SD card: Requires [[#1. Encrypt external drive]].

You may make modifications to some aspects of this setup if your treat model is different. For example, if physical access to the device is not a concern and you want the convenience of automatic setup on boot, you may choose to not encrypt the external drive.

# Requirements

- A Raspberry Pi 4/5 (min 4 GB RAM) + micro SD card.
- External storage, enough to hold all your Photos and Videos (assets).
- A cloud storage service - used for backups.

## Optional requirements

- FTDI cable - If you prefer to communicate via terminal instead of connecting a screen, keyboard and mouse to the RPi.

# The big picture

The diagram below describes the architecture of our server and how different parts of our system communicate with each other. The following sections describe each part and any required setup.

![data-flow-diagram](assets/data-flow-diagram.png)

## Glossary

- **[Raspberry Pi (RPi)](https://www.raspberrypi.com/)**: A small and cheap single-board computer.
- **Immich**: The code that runs on our RPi providing photo management features.
- **External drive**: A Solid State Drive (SSD) or Hard Disk Drive (HDD) with a USB interface.
- **Cloud storage**: A storage service provided by third parties such as Proton Drive, Backblaze, GCP, AWS, etc.
- **`rclone`/`rustic`**: Programs that facilitate backups to cloud storage.
- **`tailscale`**: VPN that allows our server to be reachable from anywhere.

## Costs

| Item/service      | Cost            |
|-------------------|-----------------|
| RPi               | ~ £ 50          |
| External drive    | £ 40 - 100      |
| Cloud storage     | £ 1 - 4 / month |
| Immich            | Free            |
| `rclone`/`rustic` | Free            |
| `tailscale`       | Free            |

# Setup steps
## 1. Encrypt external drive

We encrypt the external drive is stop anyone gaining physical access to our drive from being able to see all our assets. If this is not a concern, you can skip this step. I would encourage you to listen to [Darknet Dairies episode #163: Ola](https://open.spotify.com/episode/7K7NN1U7J2M6DOlDvKnbMq?si=dfbd5c4a83ec4830) before choosing to do so.

### Creating an encrypted drive

We need to create a LUKS encrypted drive with and ext4 file system. You can use GUI tools for this. However, to keep things consistent, we will do this from the terminal using `cryptsetup`.

1. Identify the path to your drive. On Linux you this is similar to `/dev/sd<X>`.
2. Use `cryptsetup` to encrypt the drive
   ```
   sudo cryptsetup luksFormat <drive path> --type luks2 --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random
   ```
3. Plug and decrypt the drive
   ```
   sudo cryptsetup open <drive path> <mount name>
   ```
4. Create file system
   ```
   sudo mkfs.ext4 /dev/mapper/<mount name>
   ```

> [!CAUTION]
> Securely store the encryption password. If you loose it you will loose access to all the files stored in this drive.

#### Decrypting the drive

It's as simple as plugging in the drive to you PC and typing the password when prompted by the OS. If you want to use the `cryptsetup` from the terminal:

1. Decrypt the drive
   ```
   sudo cryptsetup open /dev/sd<X> immich_drive
   ```
2. Mount the drive
   ```
   sudo mount /dev/mapper/immich_drive /mnt/immich_data
   ```

## 2. Raspberry Pi setup

This project uses a declarative Linux operating system (OS), NixOS. This allows us to bring the system into the required state from configuration files maintained in this repository without the hassle of manual installations.

NixOS will not be running on an encrypted drive. This is to allow the possibility of remote bring up if the server reboots. However, all secrets and assets will be stored on the encrypted external drive.

### Installing NixOS

These steps are simplified from [this](https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi)  original source.

1. Download the latest NixOS build for your RPi from [Hydra](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux).
2. Flash on to an SD card using your favourite flashing tool. `rpi-imager`, `balena-etcher` or `dd` will do.
3. if using an FTDI cable
	1. Enable UART
		1. Mount the SD card back on you machine.
		2. Open `NIXOS_SD/boot/extlinux/extlinux.conf`
		3. Edit the `APPEND` line by replacing `console=ttyS0,115200n8` with `console=ttyS1,115200n8`.
		4. Save
	2. Wire a USB to FTDI cable to the UART on GPIOs 14 and 15.
	3. Use `picocom -b 115200 /dev/ttyUSB<X>` to monitor the boot and log into your RPi.
4. If not using an FTDI cable, wire a screen, keyboard and mouse to the RPi.
5. Place the SD card in your RPi and power it.
6. Setup the OS
	1. Plug-in an Ethernet cable.
	2. Install git:
	   ```
	   nix-shell -p git
	   ```
	3. Clone this repository:
	   ```
	   git clone https://github.com/hicklin/immich-rpi-server.git
	   ```
	4. Create a symbolic link (shortcut), for our NixOS configuration:
	   ```
	   ln -s ~/immich-rpi-server/configuration.nix /etc/nixos/configuration.nix
	   ```
	5. Update channels:
	   ```
	   sudo nix-channel --update
	   ```
	6. Install all necessary services and applications:
	   ```
	   sudo nixos-rebuild switch
	   ```

> [!IMPORTANT]
> For improved security, setup [SSH keys and disable password authentication](https://wiki.nixos.org/wiki/SSH_public_key_authentication).

## 3. Immich setup

We will finish setting up immich, install the companion app on our phone and access the server from a web browser. For now, we will only be able to access immich from devices on the same network. We will enable remote access in [[#5. Remote access]].

### Raspberry Pi

Immich is already installed and configured on the RPi, however it requires a secrets file to operate. Follow these one-time steps to set this up.

1. Decrypt and mount the external drive.
   ```
   immich-server --immich-drive /dev/sda
   ```
2. Copy the example secrets file to your encrypted drive.
   ```
   mkdir /mnt/immich-data/secrets # If directory does not exist
   cp <path to this repo>/immich-secrets.example /mnt/immich-data/secrets/immich-secrets
   ```
3. **Change the `DB_PASSWORD` value**. Save it in your password manager.

> [!CAUTION]
> Securely store the `DB_PASSWORD`. This is necessary to recover the database which is essential to make sense of our backup.

### Phone

1. Download the immich app from https://immich.app/.
2. Set the server URL to `http://<RPi IP>:2283`. You can get the RPi IP with `ip addr show`.
3. For more information about using the app consult the [immich documentation](https://docs.immich.app/overview/quick-start#try-the-mobile-app).

### Access the web app

In your web browser type `http://<RPi IP>:2283`.  You can get the RPi IP with `ip addr show`.

### Immich initialisation

Upon first access, you will be prompted to setup the admin user.

> [!CAUTION]
> Securely store the admin credentials.

## 4. Setting up backup

It is essential that we backup our assets. Our drive may fail, get damaged or stolen and we don't want this to result in the loss our memories.

The most resilient backups are cloud storage services. However, we want to ensure that our data is encrypted and only accessible by us. To achieve this we have two options; use a **trusted end-to-end encryption and zero-trust storage service** or **encrypt the data ourselves**.

If you are embarking on this project, you are likely a secure conscious individual and may already have [Proton Mail](https://proton.me/mail). The payed plan comes with 500 GB of Proton Drive which is an end-to-end encryption and zero-trust storage service. Unfortunately, Proton Drive do not currently provide a robust solution for using this drive from Linux. If you are interested in trying to use this, read [Proton Drive Backups](proton-drive-backups.md).

### Encrypted backups with [`rustic`](https://rustic.cli.rs/docs/intro.html)

`rustic` is a fast and secure backup program. It encrypts and syncs our data to a remote location. We will use `restic` to achieve data with a similar security posture to Proton Drive on non-zero-thrust services like Backblaze, GCP, AWS, etc.

For disaster recovery we will need to upload 
- `UPLOAD_LOCATION/library/upload`: all original assets
- `UPLOAD_LOCATION/library/profile`: user profiles
- `UPLOAD_LOCATION/library/backups`: database backups

> [!TIP]
> You can configure the frequency and retention of database backups. For more information consult the [immich docs](https://docs.immich.app/administration/backup-and-restore#automatic-database-dumps).

> [!TIP]
> Just uploading these directories will require immich to regenerate thumbs and encoded-videos during recovery. These extra directories can also be backed up by backing up the entire `UPLOAD_LOCATION/library` directory. However, this can consume significantly larger space, so consider how often you might have to perform a disaster recovery vs the cost of storing this data.

#### 1. Setup a storage provider

Choose a cloud storage provider compatible with `rustic`. You can find a list of supported backends [here](https://rustic.cli.rs/docs/comparison-restic.html#supported-storage-backends). I recommend using [backblaze](https://www.backblaze.com/). It's a pay-as-you-go service with reasonable cost per TB. It's fully supported by `rustic`.

Follow the instructions by the could storage provider to setup a storage bucket and generate an application key.

#### 2. Configure rustic

Rustic requires a `.toml` configuration file with credentials to access your storage service and repository. In this context, repository refers to the stored encrypted data. You can find the latest configuration file example for backblaze and other services [here](https://github.com/rustic-rs/rustic/blob/main/config/services/b2.toml). Create a copy of the relevant example in `/mnt/immich_data/secrets` and update the values with information from your cloud storage provider.

> [!CAUTION]  
> The password in `[repository]` is what's used to encrypt/decrypt your data. **Do not loose this** otherwise you will not be able to access your data.

> [!NOTE]  
> The contents of this config contains all the necessary information to access your private data. Hence, it's important for us to keep this secure. To do this, we will store this file in the encrypted storage drive in a `secrets` directory and link it in the required directory.
> ```bash
> mkdir -p .config/rustic # If path does not exist
> ln -s /mnt/immich_data/secrets/rustic.toml ~/.config/rustic
> ```

#### 3. Initialise the repository - One time

This step initialises the backup location for rustic. We only need to run this once.

```
rustic init
```

#### 4. Manual backup

Our nix configuration provides a helper script for backing up our data.

```
immich-backup
```

This script will encrypt and backup the essential directories describe earlier.

> [!NOTE]  
> If you wish to backup non-essential files as well, set the `IMMICH_BACKUP_ALL` environment variable in `configuration.nix` to `"true"`. Remember to follow this up with `sudo nixos-rebuild switch`.

#### 5. Schedule backups

Our nix configuration schedules backups to start 15 min after boot and again every day. If you wish to modify this, you can amend `systemd.timers."immich-backup"` in `configuration.nix`.

## 5. Remote access

Our server is now set but we can't access it from outside our local network. To access our photos from outside our local network while keeping the server inaccessible to everyone else, we will create a Virtual Private Network (VPN) using tailscale.

Tailscale allows us to create a VPN that behaves similar to our local network, i.e. all devices on the same VPN will be able to communicate with each other. You can read more about how tailscale works [here](https://tailscale.com/blog/how-tailscale-works).

1. **Create an account** at https://login.tailscale.com/start.
2. **Register the RPi**. Tailscale is already installed on our RPi thanks to our NixOS configuration. To register the RPi, call this command and follow the URL output.
   ```
   sudo tailscale up
   ```
3. Install the tailscale app on you phone: https://tailscale.com/download
4. Register your phone from the tailscale app.
5. Install tailscale on other remote devices and register them in a similar way.

The [tailscale dashboard](https://login.tailscale.com/admin/machines) shows all devices registered on your VPN. To access immich remotely from a device connected to the same tailscale VPN, replace the immich local IP in step 3 with the tailscale IP for the immich device obtained from the `ADDRESSES` column.

> [!NOTE]  
> Tailscale will need to be running on devices outside the local network wishing to access immich.

> [!TIP]
> The immich app can be set up to use the local IP when you are on the home WiFi and switch to the tailscale IP otherwise. To do this go to `user icon (top right) > Settings > Networking` and enable `Automatic URL switching`.

# On reboot

If you opted out of an encrypted immich drive, there is nothing to run when the RPi reboots if the `systemd.user.units.immich.wantedBy = lib.mkForce [];` line in `configuration.nix` is commented out. Remember to run `sudo nixos-rebuild switch` after commenting it out.

Since we have an encrypted drive, and since we do not want the password to exist on the unencrypted OS memory, we have to manually input it after boot. This project provides a helper script as part of the nix configuration called `immich-server`. After boot call

```bash
immich-server --start --immich-drive /dev/sda
```

This script will first ask you for you **user password** then ask you for the **immich drive decryption password**.

> [!NOTE]
> Your drive may be in a different location than `/dev/sda`. 

# Maintenance 

You will need to perform some minimal maintenance procedures to ensure that your system is still operating securely.

## OS updates

Run the following commands to update the OS and its applications

```bash
sudo --nix-channel --update
sudo nixos-rebuild switch
```

> [!TIP]
> If you experience an issue after the update, you can always roll back to a previous build with `nixos-rebuild --rollback switch`. You can read more about `nixos-rebuild` commands [here](https://nixos.wiki/wiki/Nixos-rebuild).

## Check backup logs

Periodically check the backup logs or the cloud storage to ensure that the backup application is still working.

```bash
journalctl -xeu immich-backup.service
```

# Disaster recovery

Here we will talk about setting up the device with backed up data.