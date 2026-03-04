{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"
    ./../../profiles/aarch64-cross-compilation-fixes.nix
    ./../../profiles/headless.nix
    ./../../profiles/common.nix
    ./../../services/tor.nix
  ];

  # "scudo" from hardened profile is not available for armv7l-linux
  environment.memoryAllocator.provider = "jemalloc";

  # pkgs.efivar is broken in armv7l-linux
  nixpkgs.config.allowBroken = true;

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
