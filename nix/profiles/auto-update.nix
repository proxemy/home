{
  pkgs,
  cfg,
  secrets,
  sourceInfo,
  ...
}:
{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = cfg.homeDir;
    flags = [
      "--print-build-logs"
      # "--verbose"
      "--show-trace"
    ];
    randomizedDelaySec = "30min";
    rebootWindow = {
      lower = "03:00";
      upper = "04:00";
    };
  };

  # nixos-upgrade.service
  systemd.services.home-git-repo-update = {
    description = "Pull from remote and update lockfile. See HOMEDIR";
    requiredBy = [ "nixos-upgrade.service" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = cfg.homeDir;
      UMask="0077";
      ExecStart =
        let
          #git_args = "--work-tree=${cfg.homeDir} --git-dir=${cfg.homeDir}/.git";
          nix_args = "--extra-experimental-features nix-command";
        in
        with pkgs; [
          "${git}/bin/git fetch origin"
          "${git}/bin/git reset --hard origin/main"
          "${git-crypt}/bin/git-crypt unlock ${cfg.homeDir}/.git/git-crypt/keys/default"
          "${nix}/bin/nix ${nix_args} flake update"
        ];
    };
  };

  system.activationScripts = {
    init-home-git-repo =
      let
        home-git-repo = import ./../installer/home-git-repo.nix { inherit pkgs secrets sourceInfo; };
      in
      {
        deps = [ "etc" ];
        supportsDryActivation = false;
        text = ''
          mkdir -p ${cfg.homeDir}
          cp -r ${home-git-repo}/. ${cfg.homeDir}
        '';
      };
  };
}
