{
  pkgs,
  lib,
  secrets,
  host,
  ...
}:
{
  imports = [
    ../profiles/xfce.nix
    ../programs/firefox.nix
    ../programs/keepassxc.nix
  ];

  hardware.graphics.enable = lib.mkDefault true;

  users.users.${secrets.user_name}.packages = with pkgs; [
    # TODO: Maybe turn vlc into its own programs/vlc.nix
    vlc
    tor-browser
  ];

  # hardened allocator (scudo/graphene-hardened) often fail with desktop apps eg.firefox
  environment.memoryAllocator.provider = "libc";

  services = {
    devmon.enable = true;
    pulseaudio.enable = true;
    xserver.enable = true;

    displayManager.autoLogin =
      if host.partitions.primary.encrypt then
        {
          enable = true;
          user = secrets.user_name;
        }
      else
        { };
  };
}
