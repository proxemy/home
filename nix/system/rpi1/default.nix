{ lib, modulesPath, ... }:
{
  imports = [
    #"${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix"
    #"${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"
    #"${modulesPath}/installer/sd-card/sd-image-raspberrypi-installer.nix"
    #"${modulesPath}/installer/sd-card/sd-image-raspberrypi.nix"
    #"${modulesPath}/installer/sd-card/sd-image.nix"
    #./../common.nix
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;

  # 'scudo' the hardened allocator, loaded from common.nix, is incompatible with armv7l
  environment.memoryAllocator.provider = lib.mkForce "libc";

  #nixpkgs.hostPlatform = "armv7l-linux";
  #nixpkgs.config.allowBroken = true;
  #nixpkgs.crossSystem.system = "armv7l-linux";
  nixpkgs.buildPlatform = system;
  nixpkgs.hostPlatform = inputs.nixpkgs.lib.systems.examples.armv7l-hf-multiplatform;

  sdImage.compressImage = false;
}
