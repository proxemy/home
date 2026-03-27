{
  pkgs,
  self,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    enable = true;
    defaultEditor = true;
    #withPython3 = true; # required by YouCompleteMe
    coc = {
      enable = true;
      package = pkgs.vimPlugins.coc-nvim;
    };

    plugins =
      with pkgs.vimPlugins;
      [
        syntastic
        nvim-treesitter
        nvim-treesitter-context
        # https://github.com/RRethy/nvim-treesitter-endwise/
        # Supported Languages: Ruby, Lua, Vimscript, Bash, Elixir, Fish, Julia
        #nvim-treesitter-endwise
        rustaceanvim
        #YouCompleteMe
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
      ])

      ++ (with pkgs.vimPlugins; [
        coc-clangd
        coc-cmake
        coc-git
        coc-html
        coc-java
        coc-json
        coc-markdownlint
        coc-nvim
        coc-pyright
        coc-rust-analyzer
        coc-sh
        coc-toml
        coc-vimlsp
        coc-vimtex
      ]);

    initLua = ''
        loadfile("${self.inputs.dotfiles}/.config/nvim/init.lua")()

        -- https://github.com/nvim-treesitter/nvim-treesitter-context/
        require'treesitter-context'.setup{
          enable = true,
          multiwindow = false,
          max_lines = 2,
          line_numbers = true,
          trim_scope = 'outer',
      }
    '';
  };
}
