{
  pkgs,
  self,
  secrets,
  ...
}:
{
  imports = [
    ./treesitter.nix
    #./YouCompleteMe.nix
    ./coc.nix
  ];

  home-manager.users.${secrets.username}.programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      syntastic
      rustaceanvim
    ];
  };
}
