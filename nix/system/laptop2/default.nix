{ ... }:
{
  imports = [
    ./../../profiles/common.nix
    ./../../programs/firefox.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    supportedFilesystems = [ "ext4" ];
    loader.grub = {
      device = "/dev/sda";
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

  services = {
    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };
}
