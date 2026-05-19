{
  pkgs,
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

    file.".dotfiles_store" = {
      source = dotfiles;
      force = true;
      # workaround for missing feature: https://github.com/nix-community/home-manager/issues/3090
      onChange = ''
        umask 0077
        cp --no-preserve=all --recursive "${dotfiles}"/. ~ || true
      '';
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

  home.file = {
    ".ssh/config".force = true;
    #".config/nvim/init.lua".force = true;
  };
}
