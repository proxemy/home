{ modulesPath, self, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    "${self}/profiles/aarch64-cross-compilation-fixes.nix"
    "${self}/profiles/headless.nix"
    "${self}/profiles/common.nix"
    "${self}/services/nas_server.nix"
    "${self}/services/mpd_server.nix"
    "${self}/services/raid.nix"
  ]; # TODO exclude cross compilation fixes for native builds so native auto updates

  sdImage.compressImage = false;

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];
}
