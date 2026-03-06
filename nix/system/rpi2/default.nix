{
  lib,
  modulesPath,
  ...
}:
let
  # for initial emulated compilation, enable temporarily
  # ! DO NOT COMMIT / PUSH !
  is_cross = false;
  build_platform = "x86_64-linux";
in
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"
    ./../../profiles/headless.nix
    ./../../profiles/common.nix
    #./../../services/tor.nix
  ];

  # cross compilation fixes
  disabledModules = [
    # pkgs.efivar is imported by base.nix but broken for armv7l
    "${modulesPath}/profiles/base.nix"
  ]
  ++ (lib.optionals is_cross [
    ../../services/auto-update.nix
    ../../profiles/cli_minimal.nix
  ]);

  nixpkgs.buildPlatform = if is_cross then build_platform else null;

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
