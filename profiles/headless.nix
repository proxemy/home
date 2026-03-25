{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    # TODO enable and test this
    #"${modulesPath}/profiles/headless.nix"
  ];

  disabledModules = [
    # imported by sd-image profiles for raspis
    "${modulesPath}/profiles/base.nix"
  ];

  environment.defaultPackages = lib.mkForce [ ];

  console.enable = false;
}
