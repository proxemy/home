{
  pkgs,
  lib,
  host,
  cfg,
  secrets,
  home-manager,
  dotfiles,
  ...
}:
{
  imports = [
    secrets.module
    ./hardened.nix
    ./cli_minimal.nix
    ../services/auto-update.nix

    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${secrets.username} = import ./../home.nix { inherit cfg secrets dotfiles; };
        backupFileExtension = ".bak";
      };
    }
  ];

  nixpkgs.hostPlatform = host.platform;

  networking.hostName = host.hostname;

  nix = {
    # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    # "required to have nix beta flake support"
    package = pkgs.nixVersions.latest;

    settings = {
      trusted-users = [ secrets.username ];
      system-features = [
        "nix-command"
        "flakes"
        "big-parallel"
        "kvm"
      ];
      #auto-optimize-store = true; # optimize the store on every build, heavy IO + cpu
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    gc = {
      automatic = true;
      options = "--delete-old";
      dates = "weekly";
    };
  };

  environment.variables.HOMEDIR = cfg.home_git_dir;

  boot = {
    binfmt.emulatedSystems = lib.lists.remove host.platform cfg.supported_systems;
    loader.timeout = lib.mkDefault 2;
  };

  system = {
    inherit (cfg) stateVersion;
  };

  hardware = {
    bluetooth.enable = false;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        AllowedUsers = secrets.username;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
        X11Forwarding = false;
      };

      #generateHostKeys = false;
      #hostKeys = lib.mkForce [];

      extraConfig = ''
        Banner none
        LoginGraceTime 10
        ChallengeResponseAuthentication no
        KerberosAuthentication no
        GSSAPIAuthentication no
        AllowAgentForwarding no
        AllowTcpForwarding no
        PermitTunnel no
        PermitUserEnvironment no

        # TODO migrate to/create ssh client config
        #UseRoaming no # <- client config
      '';
    };

    pipewire.enable = false; # conflict with Pulseaudio
  };

  zramSwap = {
    enable = true;
  };
}
