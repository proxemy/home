{ modulesPath, ... }:
{
  imports = [
    #"${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform-installer.nix"
    ./../common.nix
  ];

  #nixpkgs.hostPlatform = "armv7l-linux";
}
