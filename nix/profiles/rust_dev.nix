{ pkgs, secrets, ... }:
{
  users.users.${secrets.username}.packages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    rustfmt
  ];
}
