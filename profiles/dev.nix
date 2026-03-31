{
  pkgs,
  self,
  secrets,
  ...
}:
{
  imports = [
    "${self}/programs/neovim/"
  ];

  users.users.${secrets.username}.packages = with pkgs; [
    cargo
    gcc
    rust-analyzer
    rustc
    rustfmt
    rustup
    vscodium
  ];
}
