{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];

  disabledModules = [
    # imported by sd-image profiles for raspis, breaks build
    "${modulesPath}/profiles/base.nix"
  ];

  environment.defaultPackages = lib.mkForce [ ];

  console.enable = false;

  # headless means running on various ISAs, stable is a conservative choice.
  # TODO: maybe create dedicated aarch64 profile
  nix.package = lib.mkForce pkgs.nixVersions.stable;
}
