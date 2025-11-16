{ ... }:
{
  imports = [
    ./../../profiles/desktop.nix
    ./../../profiles/common.nix
    ./../../services/nas_client.nix
  ];

  boot = {
    supportedFilesystems = [ "ext4" ];
    loader.grub = {
      device = "/dev/sda";
      enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [ { label = "swap"; } ];
}
