{
  pkgs,
  lib,
  config,
  cfg,
  secrets,
  self,
  ...
}:
let
  inherit (cfg) home_git_dir;
  git = "${pkgs.git}/bin/git";
  git-crypt = "${pkgs.git-crypt}/bin/git-crypt";
  nix = "${pkgs.nix}/bin/nix --extra-experimental-features nix-command --extra-experimental-features flakes";
  upgrade_cmd = "${lib.getBin pkgs.systemd}/bin/systemctl start ${config.systemd.services.nixos-upgrade.name} --verbose";
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
    path = [
      # required! otherwise indirect invocations fail
      pkgs.git
      pkgs.git-crypt
    ];
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
        home_git_repo = import "${self}/systems/installer/home_git_repo.nix" { inherit pkgs secrets self; };
      in
      {
        deps = [ "etc" ];
        supportsDryActivation = false;
        text = ''
          mkdir -p ${home_git_dir}
          cp -r ${home_git_repo}/. ${home_git_dir}
        '';
      };
  };

  environment = {
    shellAliases = {
      "home-goto" = "cd ${home_git_dir}";
      "home-upgrade" = "sudo ${upgrade_cmd}";
    };
  };

  security.sudo.extraRules = [
    {
      users = [ secrets.username ];
      commands = [
        {
          command = upgrade_cmd;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
