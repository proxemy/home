{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:proxemy/dotfiles";
      flake = false;
    };

    #nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      dotfiles,
    }@inputs:
    let

      cfg = {
        debug = false;
        stateVersion = "26.05";
        home_git_dir = "/etc/nixos/home";
        supported_systems = [
          "aarch64-linux"
          "armv7l-linux"
          "x86_64-linux"
        ];
      };

      secrets = import ./secrets {
        inherit (pkgs) lib;
        inherit self;
      };
      inherit (secrets) hostnames;

      forSystems = nixpkgs.lib.genAttrs cfg.supportedSystems;
      system = "x86_64-linux"; # builtins.currentSystem;
      pkgs = inputs.nixpkgs.legacyPackages.${system}; # TODO .pkgsExtraHardening;

      inherit
        (import ./lib/mk_nixos.nix {
          inherit
            inputs
            self
            cfg
            secrets
            ;
        })
        mk_nixos
        mk_installer
        ;

    in
    {
      nixosConfigurations = {

        ${hostnames.desktop1} = mk_nixos {
          host = secrets.hosts.desktop1;
        };

        "${hostnames.desktop1}-installer" = mk_installer {
          host = secrets.hosts.desktop1;
        };

        ${hostnames.laptop1} = mk_nixos {
          host = secrets.hosts.laptop1;
        };

        "${hostnames.laptop1}-installer" = mk_installer {
          host = secrets.hosts.laptop1;
        };

        ${hostnames.laptop2} = mk_nixos {
          host = secrets.hosts.laptop2;
        };

        "${hostnames.laptop2}-installer" = mk_installer {
          host = secrets.hosts.laptop2;
        };

        ${hostnames.rpi1} = mk_nixos {
          host = secrets.hosts.rpi1;
        };

        ${hostnames.rpi2} = mk_nixos {
          host = secrets.hosts.rpi2;
        };
      };

      homeConfigurations.${secrets.username} =
        self.outputs.nixosConfigurations.${hostnames.desktop1}.config.home-manager.users.${secrets.username}.home;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          git
          git-crypt
          nixos-generators
          nixos-install-tools
          nixos-option
          nixos-shell
          nixos-rebuild
          nixos-container
          pkgs.home-manager # input arg 'home-manager' would be taken otherwise
        ];

        shellHook =
          let
            inherit (hostnames) desktop1 laptop2 rpi1;
            inherit (secrets) username list_of;
          in
          ''
            echo -e "" \
            "nixos-rebuild build --flake .#${laptop2}[-installer]\n" \
            "nix run .#dd-installer -- <hostname> [<block device>]\n" \
            "nixos-generate --flake .#${rpi1} --format iso --out-link result\n" \
            "nix build .#nixosConfigurations.${rpi1}.config.system.build.sdImage\n" \
            "nix build .#nixosConfigurations.${desktop1}.config.home-manager.users.${username}.home-files\n" \
            "home-manager switch --flake .\n" \
            "Hosts: ${builtins.toString list_of.hostnames}"
          '';
      };

      apps.${system} = {
        tests = {
          type = "app";
          meta.description = "Runs a bunch of flake tests";
          program = "${pkgs.writeShellScript "home-flake-tests" ''
            echo TODO
          ''}";
        };

        dd-installer = {
          type = "app";
          meta.description = ''
            Create a nixos installer iso with a preconfigured hostname.
            The iso gets written on target device (thumb drive).
          '';
          program = "${./scripts/build-dd-installer.sh}";
        };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
