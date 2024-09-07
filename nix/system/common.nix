{
  pkgs,
  lib,
  modulesPath,
  hostName,
  cfg,
  secrets,
  home-manager,
  dotfiles,
  ...
}:
{
  imports = [
    "${modulesPath}/profiles/hardened.nix"

    home-manager.nixosModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${secrets.user.name} = import ./../home.nix { inherit cfg secrets dotfiles; };
      };
    }
  ];

  users.users = {
    ${secrets.user.name} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      initialHashedPassword = secrets.user.hashed_pw;
      createHome = true;
      #openssh.authorizedKeys = [ "TODO" ];
    };
    root = {
      initialHashedPassword = secrets.root.hashed_pw;
    };
  };

  networking.hostName = hostName;

  nix = {
    # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    # "required to have nix beta flake support"
    package = pkgs.nixVersions.latest;

    settings = {
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
      neovim
      mtr
      tree
      wget
    ];
    variables = {
      HOMEDIR = cfg.homeDir;
    };
  };

  boot.binfmt.emulatedSystems = lib.lists.remove pkgs.system cfg.supportedSystems;

  system = {
    inherit (cfg) stateVersion;
    autoUpgrade = {
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
  };

  hardware = {
    bluetooth.enable = false;
    pulseaudio.enable = true;
  };

  services = {
    openssh = lib.mkForce {
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

        #UseRoaming no # <- client config
      '';
    };
    xserver.xkb = lib.mkDefault {
      layout = "de";
      variant = "deadacute";
      options = "terminate:ctrl_alt_del";
    };
  };
}
