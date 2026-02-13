{ pkgs, ... }:
{
  programs = {
    neovim.enable = true;
    mtr.enable = true;
    tmux.enable = true;
    git.enable = true;
  };

  environment.systemPackages = with pkgs; [
    file
    htop
    lsof
    tree
    git-crypt
  ];
}
