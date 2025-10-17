{ alias }:
{
  pkgs,
  lib,
  modulesPath,
  sourceInfo,
  cfg,
  secrets,
  ...
}:
let
  host = secrets.hosts.${alias};
  host_name = secrets.hostnames.${alias};
  home-git-repo = import ./home-git-repo.nix { inherit pkgs secrets sourceInfo; };
  install-script = import ./script.nix { inherit pkgs cfg host; };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  system.stateVersion = cfg.stateVersion;

  environment = {
    # install.sh is copied in isoImage.contens[0]
    shellAliases.install = "sudo -E bash /iso/install.sh";
  };

  networking.hostName = host_name;

  services.xserver.xkb = (secrets.module {}).services.xserver.xkb;

  time = (secrets.module {}).time;

  nix = {
    package = pkgs.nixVersions.latest;
    settings.system-features = [
      "nix-command"
      "flakes"
      "big-parallel"
      "kvm"
    ];
  };

  #isoImage.storeContents = [ sourceInfo ];
  #installer.cloneConfigIncludes = [ "./common.nix" ];
  #nix.nixPath = [ "nixos-config=github:proxemy/home" ];
  #system = {
  #copySystemConfiguration = true;
  #nixos-generate-config.configuration = "asd wert";
  #};

  isoImage = {
    edition = alias;
    volumeID = "${host_name}-nixos-installer";

    # TODO: finalize a self contained/offline installer iso
    # the 2 options might be a lead. 'includeSystemBuildDeps' bloats the
    # nix/store extremly and storeContents expects JSON as input.
    #includeSystemBuildDependencies = true;

    contents = [
      {
        source = install-script;
        target = "/install.sh";
      }
      {
        source = home-git-repo;
        target = "/home-git";
      }
    ];
  };
}
