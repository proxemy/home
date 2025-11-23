{
  pkgs,
  cfg,
  secrets,
  sourceInfo,
  ...
}:
let
  inherit (cfg) home_git_dir;
  git = "${pkgs.git}/bin/git";
  git-crypt = "${pkgs.git-crypt}/bin/git-crypt";
  nix = "${pkgs.nix}/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes";
in

{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = home_git_dir;
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
      WorkingDirectory = home_git_dir;
      UMask = "0077";
      ExecStart = [
        "${git} fetch origin"
        "${git} reset --hard origin/main"
        "${git-crypt} unlock .git/git-crypt/keys/default"
        "${nix} flake update"
      ];
    };
  };

  system.activationScripts = {
    init-home-git-repo =
      let
        home-git-repo = import ./../system/installer/home-git-repo.nix { inherit pkgs secrets sourceInfo; };
      in
      {
        deps = [ "etc" ];
        supportsDryActivation = false;
        text = ''
          mkdir -p ${home_git_dir}
          cp -r ${home-git-repo}/. ${home_git_dir}
        '';
      };
  };
}
