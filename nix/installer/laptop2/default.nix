{ ... }:
{
  imports = [
    (import ./../installerMedium.nix { alias = "laptop1"; })
  ];
}
