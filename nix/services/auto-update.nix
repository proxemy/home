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

  systemd.services.home-git-repo-update = {
    description = "Pull from remote and update lockfile. See HOMEDIR";
    before = [ "nixos-upgrade.service" ];
    requiredBy = [ "nixos-upgrade.service" ];
    path = [ pkgs.git-crypt ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = cfg.homeDir;
      UMask = "0077";
      ExecStart =
        with pkgs;
        let
        in
        #git_args = "--work-tree=${cfg.homeDir} --git-dir=${cfg.homeDir}/.git";
        #nix_args = "--extra-experimental-features nix-command --extra-experimental-features falkes";
        [
          "${git}/bin/git checkout main --quiet"
          "${git}/bin/git reset --hard --quiet"
          "${git}/bin/git pull origin main --quiet"
          "${git}/bin/git branch --verbose"
          "${git-crypt}/bin/git-crypt unlock .git/git-crypt/keys/default"
          # TODO enable flake.lock upgrade after some testing of failure conditions
          #"${nix}/bin/nix ${nix_args} flake update"
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
