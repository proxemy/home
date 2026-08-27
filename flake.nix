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

      pkgs = inputs.nixpkgs.legacyPackages.${system}; # TODO .pkgsExtraHardening;
      lib = nixpkgs.lib;
      forSystems = lib.genAttrs cfg.supportedSystems;
      system = "x86_64-linux"; # builtins.currentSystem;

      secrets = import ./secrets { inherit lib self; };

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
      # for quick repl testing
      inherit pkgs secrets;

      nixosConfigurations = lib.concatMapAttrs (
        alias: host:
        {
          "${host.hostname}" = mk_nixos { inherit host; };
        }
        // lib.optionalAttrs (host.with_installer) {
          "${host.hostname}-installer" = mk_installer { inherit host; };
        }
      ) secrets.hosts;

      homeConfigurations.${secrets.username} =
        self.outputs.nixosConfigurations.${secrets.hostnames.desktop1}.config.home-manager.users.${secrets.username}.home
        # weird fix to make 'home-manager switch' not complain about missing news
        // {
          config.news.json.output = pkgs.writeText "dummy-hm-news.json" (
            builtins.toJSON {
              entries = [ ];
              display = "silent";
            }
          );
        };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
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
            inherit (secrets) username list_of;
          in
          with secrets.hostnames;
          ''
            echo -e "" \
            "nixos-rebuild build --flake .#${laptop2}[-installer]\n" \
            "nix run .#dd_installer -- <hostname> [<block device>]\n" \
            "nixos-generate --flake .#${rpi1} --format iso --out-link result\n" \
            "nix build .#nixosConfigurations.${rpi1}.config.system.build.sdImage\n" \
            "nix build .#nixosConfigurations.${desktop1}.config.home-manager.users.${username}.home-files\n" \
            "home-manager switch --flake .\n" \
            "nixos-option --flake .#${rpi2} --recursive boot.kernelPackages.kernel\n" \
            "Hosts: ${builtins.toString list_of.hostnames}"
          '';
      };

      apps.${system} = {
        test_build_all = {
          type = "app";
          meta.description = "Build all nixosConfigurations.";
          program = "${import ./tests/build_all.nix {
            inherit pkgs self;
            inherit (secrets.list_of) hostnames;
          }}";
        };

        test_shellcheck_all = {
          type = "app";
          meta.description = "Shellcheck all sh files pedantically.";
          program = "${import ./tests/shellcheck_all.nix { inherit pkgs self; }}";
        };

        dd_installer = {
          type = "app";
          meta.description = ''
            Create a nixos installer iso with a preconfigured hostname.
            The iso gets written on target device (thumb drive).
          '';
          program = "${./scripts/build_dd_installer.sh}";
        };
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
