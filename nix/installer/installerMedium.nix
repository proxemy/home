{ alias }:
{
  pkgs,
  modulesPath,
  secrets,
  sourceInfo,
  ...
}:
let
  home-git-repo = import ./../home-git-repo.nix { inherit pkgs secrets sourceInfo; };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
    ./common.nix
  ];

  #installer.cloneConfigIncludes = [ "./common.nix" ];
  #nix.nixPath = [ "nixos-config=github:proxemy/home" ];
  #system = {
  #copySystemConfiguration = true;
  #nixos-generate-config.configuration = "asd wert";
  #};

  isoImage = {
    edition = alias;
    isoBaseName = "${alias}-nixos";
    volumeID = "${alias}-nixos";

    # TODO: finalize a self contained/offline installer iso
    # the 2 options might be a lead. 'includeSystemBuildDeps' bloats the
    # nix/store extremly and storeContents expects JSON as input.
    #includeSystemBuildDependencies = true;

    contents = [
      # TODO once the shell scripts have been split up, rename target files
      {
        source = sourceInfo + "/nix/installer/${alias}/install.sh";
        target = "/install.sh";
      }
      {
        source = home-git-repo;
        target = "/home-git";
      }
    ];
  };
}
