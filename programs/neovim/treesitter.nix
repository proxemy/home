{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    plugins =
      with pkgs.vimPlugins;
      [
        nvim-treesitter
        nvim-treesitter-context
        # https://github.com/RRethy/nvim-treesitter-endwise/
        # Supported Languages: Ruby, Lua, Vimscript, Bash, Elixir, Fish, Julia
        #nvim-treesitter-endwise
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

    initLua = ''
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
