{ ... }:
{
  # https://nixos.wiki/wiki/Steam
  programs.steam.enable = true;

  nixpkgs.config.allowUnfree = true;
}
