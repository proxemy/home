{ ... }:
{
  imports = [
    (import ./../installerMedium.nix { alias = "laptop2"; })
  ];
}
