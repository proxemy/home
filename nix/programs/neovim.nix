{ pkgs, secrets, ... }:
{
  imports = [
    # TODO: maybe split neovim/dev profiles into minimum/full
    ../profiles/rust_dev.nix
  ];

  home-manager.users.${secrets.username}.programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = true; # required by YouCompleteMe

    plugins =
      with pkgs.vimPlugins;
      [
        syntastic
        nvim-treesitter
        nvim-treesitter-endwise
        nvim-treesitter-context
        rustaceanvim
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
  users.users.${secrets.username}.packages = with pkgs; [
    gcc
    python3
  ];
}
