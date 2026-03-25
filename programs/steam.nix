{ ... }:
{
  # https://nixos.wiki/wiki/Steam
  programs.steam.enable = true;

  nixpkgs.config.allowUnfreePackages = [
    "steam"
    "steam-unwrapped"
  ];

  # disabled by hardening profile but steam relies on it
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
}
