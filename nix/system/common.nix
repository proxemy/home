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
    secrets.module
    ./auto-update.nix

    home-manager.nixosModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${secrets.userName} = import ./../home.nix { inherit cfg secrets dotfiles; };
      };
    }
  ];

  networking.hostName = hostName;

  nix = {
    # https://www.tweag.io/blog/2020-07-31-nixos-flakes/
    # "required to have nix beta flake support"
    package = pkgs.nixVersions.latest;

    settings = {
      trusted-users = [ secrets.userName ];
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
    ];
    variables = {
      HOMEDIR = cfg.homeDir;
    };
  };

  programs = lib.mkDefault {
    neovim.enable = true;
  };

  boot.binfmt.emulatedSystems = lib.lists.remove pkgs.system cfg.supportedSystems;

  system = {
    inherit (cfg) stateVersion;
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

        # TODO migrate to/create ssh client config
        #UseRoaming no # <- client config
      '';
    };

    xserver.xkb = lib.mkDefault {
      layout = "de";
      variant = "deadacute";
      options = "terminate:ctrl_alt_del";
    };

    pipewire.enable = false; # conflict with Pulseaudio
  };
}
