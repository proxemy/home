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
    rustc-unwrapped
    rustfmt
    clippy
    #rustup
  ];
in

{
  imports = [
    "${self}/programs/neovim/"
  ];

  users.users.${secrets.username}.packages =
    with pkgs;
    [
      gcc
      vscodium
    ]
    ++ rust_tools;
}
