{ lib, secrets, ... }:
{
  imports = [
    ./../../profiles/desktop.nix
    ./../../profiles/common.nix
    ./../../services/nas_client.nix
  ];

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;

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
