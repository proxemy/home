{ secrets, ... }:
{
  imports = [
    ./../../profiles/desktop.nix
    ./../../profiles/common.nix
    ./../../services/nas_client.nix
  ];

  # TODO: remove line below after testing
  #nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    supportedFilesystems = [ "ext4" ];
    loader.grub = {
      device = "/dev/sdb";
      enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [ { label = "swap"; } ];
}
