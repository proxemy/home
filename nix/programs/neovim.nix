{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins =
      with pkgs.vimPlugins;
      [
        syntastic
        nvim-treesitter
        YouCompleteMe
      ]
      ++ (with pkgs.vimPlugins.nvim-treesitter-parsers; [
        bash
        c
        c_sharp
        cpp
        dockerfile
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
        html
        java
        latex
        lua
        markdown
        nix
        python
        regex
        rust
        sql
        vim
        vimdoc
      ]);
  };

  # dependencies
  environment = {
    systemPackages = with pkgs; [
      gcc
      python3
    ];
  };
}
