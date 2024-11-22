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
    description = "Pull from remote and update lockfile. See $HOMEDIR";
    requiredBy = [ "nixos-upgrade.service" ]; # created by system.autoUpgrade.enable above
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          git_args = "--work-tree=${cfg.homeDir} --git-dir=${cfg.homeDir}/.git";
        in
        ''
          chown -R $USER:$USER ${cfg.homeDir}
          chmod -R u+rwx,go+r-wx ${cfg.homeDir}
          ${pkgs.git}/bin/git ${git_args} fetch origin
          ${pkgs.git}/bin/git ${git_args} reset --hard origin/main
          ${pkgs.nix}/bin/nix flake update ${cfg.homeDir}
        '';
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
