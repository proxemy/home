{ pkgs, ... }:
{
  programs = {
    neovim.enable = true;
  };

  # neovim/plugins dependencies
  environment = {
    systemPackages = with pkgs; [
      gcc
      python3
    ];
  };
}
