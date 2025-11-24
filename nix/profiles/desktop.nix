{ secrets, pkgs, ... }:
{
  imports = [
    ../profiles/xfce.nix
    ../programs/firefox.nix
    ../programs/keepassxc.nix
  ];

  users.users.${secrets.user_name}.packages = [
    # TODO: Maybe turn vlc into its own programs/vlc.nix
    pkgs.vlc
  ];

  # hardened allocator (scudo/graphene-hardened) often fail with desktop apps eg.firefox
  environment.memoryAllocator.provider = "libc";

  services = {
    pulseaudio.enable = true;
    xserver.enable = true;
  };
}
