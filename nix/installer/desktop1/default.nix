{ ... }:
{
  imports = [
    (import ./../installerMedium.nix { alias = "desktop1"; })
  ];
}
