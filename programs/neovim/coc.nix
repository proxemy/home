{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.neovim = {
    coc = {
      enable = true;
      package = pkgs.vimPlugins.coc-nvim;
    };

    plugins = with pkgs.vimPlugins; [
      coc-clangd
      coc-cmake
      coc-git
      #coc-html
      #coc-java
      coc-json
      coc-markdownlint
      coc-nvim
      coc-pyright
      coc-rust-analyzer
      coc-sh
      #coc-toml
      #coc-vimlsp
      #coc-vimtex
    ];

    # set <cr> to pick selected completion
    # https://github.com/neoclide/coc.nvim/wiki/Completion-with-sources
    initLua = ''
      vim.cmd( [[
        inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
      ]] )
    '';
  };
}
