{ config, pkgs, lib, ... }:

let
  user = "hicklin";
  password = "testing"; # Access to the Raspberry Pi
  hostname = "immich";
  immich-server = pkgs.writeShellScriptBin "immich-server" (builtins.readFile ./scripts/immich-server.sh);
  immich-backup = pkgs.writeShellScriptBin "immich-backup" (builtins.readFile ./scripts/immich-backup.sh);
in {

  boot = {
    # This linux_rpi4 kernel dose not work for UART. See issue https://github.com/NixOS/nixpkgs/issues/465278
    # Switching to vanilla kernel.
    # kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    kernelPackages = pkgs.linuxPackages;
    kernelParams = lib.mkForce [
        "console=ttyS1,115200n8"
        "console=ttyAMA0,115200n8"
        "console=tty0"
        "nohibernate"
        "loglevel=7"
      "lsm=landlock,yama,bpf"
    ];
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 2283 ];
      # required for Tailscale
      checkReversePath = "loose";  # Required for Tailscale exit nodes
      trustedInterfaces = [ "tailscale0" ];
    };
  };

  environment.systemPackages = with pkgs; [ 
    git
    cryptsetup
    rustic
    vim # basic file editing
    bat # a flying cat
    htop # interactive process viewer
    gtop # graphical system monitoring dashboard for the terminal
    immich-server # Helper script to run immich
    immich-backup # Helper script to backup immich data
  ];

  environment.variables = {
    # Set to "true" to include non-essential data in backup
    IMMICH_BACKUP_ALL = "false";
  };

  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.immich = {
    enable = true;
    # use `host = "::";` for IPv6.
    host = "0.0.0.0";
    port = 2283;
    secretsFile = "/mnt/immich_data/secrets/immich-secrets";
  };

  # We do not want immich to start on boot since we need to first decrypt the drive.
  # Remove this line if your immich drive does not require decryption.
  systemd.user.units.immich.wantedBy = lib.mkForce [];

  systemd.timers."immich-backup" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15m";
        OnUnitActiveSec = "1d";
        Unit = "immich-backup.service";
      };
  };

  systemd.services."immich-backup" = {
    path = [ pkgs.rustic ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${immich-backup}/bin/immich-backup";
    };
    description = "Immich backup service";
  };

  users = {
    mutableUsers = false;
    users."${user}" = {
      isNormalUser = true;
      password = password;
      extraGroups = [ "wheel" ];
    };
  };

  imports = [
    ./zsh.nix
  ];

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}