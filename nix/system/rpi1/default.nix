{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    "${modulesPath}/system/boot/loader/raspberrypi/raspberrypi.nix"
    ./../aarch64-cross-compilation-fixes.nix
    ./../common.nix
  ]; # TODO exclude cross compilation fixes for native builds so native auto updates
  #  can pick up the formerly excluded features
  # requires passed down builtins.currentSystem, which is flake-impure ...
  /*
    +++ (
      if stdenv.buildPlatform.system != stdenv.hostPlatform.system
      then []
      else []
    );
  */

  boot.loader.raspberryPi.version = 4;

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
