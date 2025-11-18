{ secrets, pkgs, ... }:
{
  imports = [
    ../profiles/xfce.nix
    ../programs/firefox.nix
  ];

  users.users.${secrets.user_name}.packages = [
    pkgs.vlc
  ];

  # hardened allocator (scudo/graphene-hardened) often fail with desktop apps eg.firefox
  environment.memoryAllocator.provider = "libc";

  services = {
    pulseaudio.enable = true;
    xserver.enable = true;
  };
}
