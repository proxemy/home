{ lib, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    # TODO enable and test this
    #"${modulesPath}/profiles/headless.nix"
  ];

  environment.defaultPackages = lib.mkForce [ ];

  console.enable = false;
}
