{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    ./../../profiles/aarch64-cross-compilation-fixes.nix
    ./../../profiles/headless.nix
    ./../../profiles/common.nix
  ]; # TODO exclude cross compilation fixes for native builds so native auto updates

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
