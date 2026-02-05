{ config, pkgs, lib, secrets, ... }:
{
  imports = [
    ./../../profiles/desktop.nix
    ./../../profiles/common.nix
    ./../../services/nas_client.nix
  ];

  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    enableRedistributableFirmware = true;
    nvidia = {
      open = true;
      gsp.enable = true;
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    cpu.amd = {
      updateMicrocode = true;
      ryzen-smu.enable = false;
    };
  };

  # TMP
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
  ];

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
