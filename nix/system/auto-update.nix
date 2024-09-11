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
      # "-L" "--verbose"
      "--show-trace"
    ]; # extended build logs
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
      ExecStart = ''
        cd ${cfg.homeDir}
        ${pkgs.git}/bin fetch origin
        ${pkgs.git}/bin reset --hard origin/main
        ${pkgs.nix}/bin flake update
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
