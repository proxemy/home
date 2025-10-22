{
  pkgs,
  lib,
  host_name,
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
    ./cli_full.nix # TODO: remove cli tools completely once tinkering with life systems is over. Minimal device setups ftw.
    ../services/auto-update.nix

    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${secrets.user_name} = import ./../home.nix { inherit cfg secrets dotfiles; };
      };
    }
  ];

  networking.hostName = host_name;

  nix = {
    # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    # "required to have nix beta flake support"
    package = pkgs.nixVersions.latest;

    settings = {
      trusted-users = [ secrets.user_name ];
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

  environment = {
    systemPackages = with pkgs; [
      git
      git-crypt
      tmux
      mtr
      tree
      wget
      htop
      lsof
    ];
    variables = {
      HOMEDIR = cfg.home_git_dir;
    };
  };

  boot = {
    binfmt.emulatedSystems = lib.lists.remove pkgs.system cfg.supported_systems;
    loader.timeout = 0;
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
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        UseDns = false;
        X11Forwarding = false;
      };
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
