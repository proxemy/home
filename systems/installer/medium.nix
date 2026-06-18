{ host }:
{
  pkgs,
  modulesPath,
  self,
  cfg,
  secrets,
  ...
}:
let
  home_git_repo = import ./home_git_repo.nix { inherit pkgs secrets self; };
  install_script = import ./script.nix { inherit pkgs cfg host; };
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  nixpkgs.hostPlatform = host.platform;

  system.stateVersion = cfg.stateVersion;

  environment = {
    # install.sh is copied in isoImage.contens[0]
    shellAliases.install = "sudo -E bash /iso/install.sh";
    systemPackages = [ pkgs.e2fsprogs ];
  };

  networking.hostName = host.hostname;

  services.xserver.xkb = (secrets.module { }).services.xserver.xkb;

  console = {
    useXkbConfig = true;
    font = "ter-c32b";
  };

  time = (secrets.module { }).time;

  nix = {
    package = pkgs.nixVersions.latest;
    settings.system-features = [
      "nix-command"
      "flakes"
      "big-parallel"
      "kvm"
    ];
  };

  isoImage = {
    edition = host.hostname;
    volumeID = "${host.hostname}-nixos-installer";

    includeSystemBuildDependencies = true;
    storeContents =
      let
        nixosCfg = self.outputs.nixosConfigurations.${host.hostname}.config;
      in
      [
        nixosCfg.environment.systemPackages
        nixosCfg.home-manager.users.${secrets.username}.home.packages
      ];

    contents = [
      {
        source = install_script;
        target = "/install.sh";
      }
      {
        source = home_git_repo;
        target = "/home-git";
      }
    ];
  };
}
