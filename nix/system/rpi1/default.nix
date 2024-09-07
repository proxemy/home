{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    ./../common.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
}
