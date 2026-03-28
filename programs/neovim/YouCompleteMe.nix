{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    plugins = [ pkgs.vimPlugins.YouCompleteMe ];
  };
}
