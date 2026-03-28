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
    vscodium
    cargo
    rustc
    rust-analyzer
    rustfmt
  ];
}
