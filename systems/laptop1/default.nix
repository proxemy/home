{
  lib,
  self,
  secrets,
  ...
}:
{
  imports = [
    "${self}/profiles/desktop.nix"
    "${self}/profiles/common.nix"
    "${self}/services/nas_client.nix"
  ];

  home-manager.users.${secrets.username}.xfconf.settings = {
    displays."Default/eDP-1/Scale" = 0.79998779296875; # Scale factor 1.25
  };

  boot = {
    supportedFilesystems = [ "ext4" ];
    loader = {
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
      grub = {
        device = "nodev";
        enable = true;
        efiSupport = true;
      };
    };
    initrd = {
      luks.devices.cryptroot.device = "/dev/disk/by-partlabel/root";
      kernelModules = [ "cryptd" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      neededForBoot = true;
    };
    "/" = {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [
    {
      device = lib.mkForce "/.swapfile";
      label = "swap";
    }
  ];
}
