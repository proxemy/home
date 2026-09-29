{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.home.packages = [
    pkgs.discord
  ];

  nixpkgs.config.allowUnfreePackages = [ "discord" "discord-unwrapped" ];
}
