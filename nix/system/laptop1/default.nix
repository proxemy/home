{ lib, secrets, ... }:
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
      luks.devices.cryptroot.device = "/dev/disk/by-partlabel/nixos";
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
      device = "/dev/disk/by-label/nixos";
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
