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

  nixpkgs = {
    buildPlatform = "x86_64-linux";
    hostPlatform = "aarch64-linux";
  };

  sdImage.compressImage = false;

  # TODO Disabled for testing, since 'swapDevice' might fully create a swapfile
  /*sdImage.postBuildCommands = ''
    dd if=/dev/zero of="$out"/swapfile bs=1024 count=$((1024*1024*8))
    chmod 0600 "$out"/swapfile
    mkswap "$out"/swapfile
  '';*/

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
