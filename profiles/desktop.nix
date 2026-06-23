{
  pkgs,
  lib,
  self,
  secrets,
  host,
  cfg,
  ...
}:
{
  imports = [
    "${self}/profiles/xfce.nix"
    "${self}/profiles/cli_full.nix"
    "${self}/profiles/feedreaders.nix"
    "${self}/programs/firefox.nix"
    "${self}/programs/keepassxc.nix"
    "${self}/programs/office_package.nix"
    "${self}/programs/thunderbird.nix"
    "${self}/programs/vlc.nix"
    "${self}/programs/redshift.nix"
  ];

  hardware = {
    graphics.enable = lib.mkDefault true;
    #enableAllHardware = true;
    #enableAllFirmware = true;
  };

  boot.kernelModules = [
    "usb-storage"
    "uas"
    "iso9660"
  ];

  home-manager.users.${secrets.username}.services.udiskie.enable = true;

  users.users.${secrets.username}.packages = with pkgs; [
    ffmpeg
    tor-browser
    torsocks
    yt-dlp
  ];

  # hardened allocator (scudo/graphene-hardened) often fail with desktop apps eg.firefox
  environment.memoryAllocator.provider = lib.mkForce "libc";

  boot.binfmt.emulatedSystems = lib.lists.remove host.platform cfg.supported_systems;

  services = {
    devmon.enable = true;
    pulseaudio.enable = true;
    xserver.enable = true;

    displayManager.autoLogin =
      if host.partitions.primary.encrypt then
        {
          enable = true;
          user = secrets.username;
        }
      else
        { };
  };
}
