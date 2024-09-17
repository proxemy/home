{ lib, modulesPath, cfg, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    ./../common.nix
  ];

  #boot.supportedFilesystems.zfs = lib.mkForce false;
  #security.apparmor.enable = lib.mkForce false;

  # 'scudo' the hardened allocator, loaded from common.nix, is incompatible with armv7l
  #environment.memoryAllocator.provider = lib.mkForce "libc";

  nixpkgs.buildPlatform = "x86_64-linux";
  nixpkgs.hostPlatform = "aarch64-linux";
  #nixpkgs.config.allowUnsupportedSystem = true;
  #nixpkgs.config.allowBroken = true;

  system = {
    inherit (cfg) stateVersion;
  };

  sdImage.compressImage = false;
}
