{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    ./../../profiles/headless.nix
    ./../../profiles/common.nix
    ./../../services/tor.nix
    ./../../services/i2p.nix
  ];

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
