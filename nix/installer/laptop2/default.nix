{
  pkgs,
  lib,
  modulesPath,
  secrets,
  sourceInfo,
  ...
}:
let
  home-git = import ./../home-git.nix { inherit pkgs secrets sourceInfo; };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    ./../common.nix
  ];

  #installer.cloneConfigIncludes = [ "./common.nix" ];
  #nix.nixPath = [ "nixos-config=github:proxemy/home" ];
  #system = {
  #copySystemConfiguration = true;
  #nixos-generate-config.configuration = "asd wert";
  #};

  isoImage = {
    edition = lib.mkForce "laptop2";
    isoBaseName = "laptop2-nixos";
    volumeID = "laptop2-nixos";

    # TODO: finalize a self contained/offline installer iso
    # the 2 options might be a lead. 'includeSystemBuildDeps' bloats the
    # nix/store extremly and storeContents expects JSON as input.
    #includeSystemBuildDependencies = true;

    contents = [
      # TODO once the shell scripts have been split up, rename target files
      {
        source = sourceInfo + "/nix/installer/laptop2/install.sh";
        target = "/install.sh";
      }
      {
        source = home-git;
        target = "/home-git";
      }
    ];
  };
}
