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

    file.".dotfiles_copy" = {
      source = dotfiles;
      # workaround for missing feature: https://github.com/nix-community/home-manager/issues/3090
      onChange = ''
        umask 0077
        cp --recursive "${dotfiles}"/. ~
      '';
      force = true;
    };
  };

  programs = {
    bash = {
      enable = true;
      #.bash_aliases lives in dotfiles
      initExtra = ''
        test -f ~/.bash_aliases && source ~/.bash_aliases
      '';
    };
  };
}
