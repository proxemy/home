{ pkgs, self, secrets, ... }:
let
  # TODO: maybe create a dedicated rust_dev profile
  rust_tools = with pkgs; [
    cargo
    rust-analyzer
    rustc-unwrapped
    rustfmt
    clippy
    #rustup
  ];
in

{
  imports = [
    "${self}/programs/neovim/"
    "${self}/programs/vscodium.nix"
  ];

  users.users.${secrets.username}.packages = [
    pkgs.gcc
  ]
  ++ rust_tools;
}
