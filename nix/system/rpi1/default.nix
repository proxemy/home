{ lib, modulesPath, cfg, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    ./../aarch64-cross-compilation-fixes.nix
    ./../common.nix
  ];

  nixpkgs = {
    buildPlatform = "x86_64-linux";
    hostPlatform = "aarch64-linux";
  };

  system = {
    inherit (cfg) stateVersion;
  };

  sdImage.compressImage = false;
}
