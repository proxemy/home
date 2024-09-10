{ lib, modulesPath, ... }:
{
  imports = [
    #"${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    #"${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix"
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"
    #"${modulesPath}/installer/sd-card/sd-image-raspberrypi-installer.nix"
    ./../common.nix
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;

  # 'scudo' the hardened allocator, loaded from common.nix, is incompatible with armv7l
  environment.memoryAllocator.provider = lib.mkForce "libc";

  nixpkgs.hostPlatform = "armv7l-linux";

  sdImage.compressImage = false;
}
