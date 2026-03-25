{
  pkgs,
  lib,
  self,
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
    "${self}/profiles/hardened.nix"
    "${self}/profiles/cli_minimal.nix"
    "${self}/services/auto-update.nix"
    "${self}/services/sshd.nix"

  home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${secrets.username} = import "${self}/profiles/home.nix" { inherit cfg secrets dotfiles; };
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

  boot.loader.timeout = lib.mkDefault 2;

  system = {
    inherit (cfg) stateVersion;
  };

  hardware.bluetooth.enable = false;

  services.pipewire.enable = false; # conflict with Pulseaudio

  zramSwap.enable = true;
}
