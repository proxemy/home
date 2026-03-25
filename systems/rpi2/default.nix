{ pkgs, modulesPath, self, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    "${self}/profiles/headless.nix"
    "${self}/profiles/common.nix"
    "${self}/services/tor.nix"
    "${self}/services/i2p.nix"
  ];

  environment.systemPackages = with pkgs; [
    iftop
  ];

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
