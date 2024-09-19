{ lib, modulesPath, cfg, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    "${modulesPath}/system/boot/loader/raspberrypi/raspberrypi.nix"
    ./../aarch64-cross-compilation-fixes.nix
    ./../common.nix
  ];

  boot.loader.raspberryPi.version = 4;

  nixpkgs = {
    buildPlatform = "x86_64-linux";
    hostPlatform = "aarch64-linux";
  };

  system = {
    inherit (cfg) stateVersion;
  };

  sdImage.compressImage = false;
}
