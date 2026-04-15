{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    plugins = [ pkgs.vimPlugins.YouCompleteMe ];

    # TODO: Get custom YCM server compilation running.
  };
}
