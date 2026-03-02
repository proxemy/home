{ pkgs, secrets, ... }:
{
  imports = [
    ../programs/neovim.nix
  ];

  users.users.${secrets.username}.packages = with pkgs; [
    vscodium
    cargo
    rustc
    rust-analyzer
    rustfmt
  ];
}
