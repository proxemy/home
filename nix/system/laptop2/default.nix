{
  pkgs,
  lib,
  cfg,
  secrets,
  ...
}:
{
  imports = [
    ./../common.nix
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

  users.users = {
    ${secrets.user.name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialHashedPassword = secrets.user.hashed_pw;
      createHome = true;
      #openssh.authorizedKeys = [ "TODO" ];
    };
    root = {
      initialHashedPassword = secrets.root.hashed_pw;
    };
  };

  networking.hostName = secrets.hostNames.laptop2;

  services = {
    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };
}
