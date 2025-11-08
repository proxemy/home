{ secrets, ... }:
{
  imports = [
    ../profiles/xfce.nix
    ../programs/firefox.nix
  ];

  # hardened allocator (scudo/graphene-hardened) often fail with desktop apps eg.firefox
  environment.memoryAllocator.provider = "libc";

  services = {
    pulseaudio.enable = true;
    xserver.enable = true;
  };
}
