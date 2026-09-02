{
  pkgs,
  lib,
  config,
  self,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username} = {
    programs.vscodium = {
      enable = config.hardware.graphics.enable;

      profiles.default.extensions = with pkgs.vscode-extensions; [
        rust-lang.rust-analyzer
      ];
    };
  };
}
