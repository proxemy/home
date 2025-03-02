{ lib, ... }:
{
  # zfs is broken and dedicated '-no-zfs.nix' profile is missing
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Apparmor is marked broken on aarch64
  #security.apparmor.enable = lib.mkForce false;

  # 'scudo', the hardened setting, pulls in llvm which does not cross compile
  #environment.memoryAllocator.provider = lib.mkForce "libc";

  # neovim requires ruby which doesnt cross compile
  #programs.neovim.enable = lib.mkForce false;
}
