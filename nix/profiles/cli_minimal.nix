{ pkgs, secrets, ... }:
{
  programs = {
    neovim.enable = true;
    mtr.enable = true;
    tmux.enable = true;
    git.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git-crypt
  ];

  users.users.${secrets.username}.packages = with pkgs; [
    file
    htop
    lsof
    tree
    wget
  ];
}
