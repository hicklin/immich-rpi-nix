# Build RPi image locally

If you are developing or want to modify the starting RPi image, you'll want to build the image locally. Follow the relevant instructions for your system.

## NixOS

1. Enable QEMU emulation of `aarch64` by adding the following to your `configuration.nix`
   ```nix
   boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
   ```
2. Build the RPi SD image with:
   ```nix
   nix build .#rpi-image
   ```

> [!NOTE]
> This builds the initial RPi SD image using the `sd_card_configuration.nix` configuration.
> This image has the bare necessities to get started, keeping it small.
> If you want to build the final image, from `configuration.nix`, update `flake.nix` accordingly before running `nix build`.
