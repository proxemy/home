{
  cfg,
  secrets,
  dotfiles,
  ...
}:
{
  home = rec {
    inherit (cfg) stateVersion;

    username = secrets.user_name;
    homeDirectory = "/home/${username}";

    file."dotfiles" = {
      source = dotfiles;
      target = "fakedir/.."; # ugly trick to link files directly into $HOME
      recursive = true;
    };
  };

  programs = {
    git = {
      enable = true;
      #extraConfig.include = { path = "~/.config/gitconfig/proxemy" };
    };
    bash = {
      enable = true;
      #.bash_aliases lives in dotfiles
      initExtra = ''
        test -f ~/.bash_aliases && source ~/.bash_aliases
      '';
    };
  };
}
