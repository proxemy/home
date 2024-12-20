{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    "${modulesPath}/system/boot/loader/raspberrypi/raspberrypi.nix"
    ./../../profiles/aarch64-cross-compilation-fixes.nix
    ./../../profiles/common.nix
    ./../../profiles/nas_server.nix
    ./../../profiles/raid.nix
  ]; # TODO exclude cross compilation fixes for native builds so native auto updates

  boot.loader.raspberryPi.version = 4;

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
