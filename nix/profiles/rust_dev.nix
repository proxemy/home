{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    rustc
    rust-analyzer
    rustfmt
  ];
}
