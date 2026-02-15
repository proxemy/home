{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cargo
    rustc
    rust-analyzer
    rustfmt
  ];
}
