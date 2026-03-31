{
  pkgs,
  self,
  secrets,
  ...
}:

let
  rust_tools = with pkgs; [
    cargo
    rust-analyzer
    rustc
    rustfmt
  ];
in

{
  imports = [
    "${self}/programs/neovim/"
  ];

  users.users.${secrets.username}.packages = with pkgs; [
    gcc
    rustup
    vscodium
  ]; # ++ rust_tools;
}
