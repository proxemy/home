{
  cfg,
  secrets,
  dotfiles,
  ...
}:
{
  home = rec {
    inherit (cfg) stateVersion;

    username = secrets.username;
    homeDirectory = "/home/${username}";

    file.".dotfiles_copy" = {
      source = dotfiles;
      # workaround for missing feature: https://github.com/nix-community/home-manager/issues/3090
      onChange = ''
        umask 0077
        # swallow all errors because some read-only files have been created
        # by home-manager already
        cp --recursive "${dotfiles}"/. ~ || true
      '';
      force = true;
    };
  };

  programs = {
    bash = {
      enable = true;
      initExtra = "source ${dotfiles}/.bash_aliases";
    };
    ssh.includes = [ "${dotfiles}/.ssh/config" ];
    neovim.initLua = ''
      loadfile("${dotfiles}/.config/nvim/init.lua")()
    '';
  };
}
