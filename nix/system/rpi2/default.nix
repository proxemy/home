{
  pkgs,
  lib,
  modulesPath,
  config,
  ...
}:
let
  # remove import of
  helpers = import ../../lib/helpers.nix { inherit pkgs lib config; };
  armv7_image = helpers.strip_profile_imports "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix";
in
{
  imports = [
    armv7_image
    "${modulesPath}/installer/sd-card/sd-image.nix"
    ./../../profiles/headless.nix
    ./../../profiles/common.nix
    ./../../services/tor.nix
  ];

  # for initial emulated compilation, enable temporarily
  # ! DO NOT COMMIT / PUSH !
  #nixpkgs.buildPlatform = "x86_64-linux";

  # "scudo" from hardened profile is not available for armv7l-linux
  environment.memoryAllocator.provider = "jemalloc";

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
