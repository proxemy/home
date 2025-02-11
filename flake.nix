{
  description = "TODO";

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
        stateVersion = "24.11";
        homeDir = "/etc/nixos/home";
        supportedSystems = [
          "aarch64-linux"
          #"armv7l-linux"
          "x86_64-linux"
        ];
      };

      forSystems = nixpkgs.lib.genAttrs cfg.supportedSystems;
      system = "x86_64-linux"; # builtins.currentSystem;
      nixpkgs = inputs.nixpkgs.legacyPackages.${system};

      secrets = import ./nix/secrets { inherit nixpkgs; };
      inherit (secrets) hostnames;

      mkNixosSys =
        {
          alias,
          system,
          module ? ./nix/system/${alias},
        }:
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit (self) sourceInfo;
            inherit
              cfg
              secrets
              dotfiles
              home-manager
              ;
            host_name = hostnames.${alias};
          };
          modules = [ module ];
        };
    in
    {
      nixosConfigurations = {

        /* TODO
        ${hostnames.desktop1} = mkNixosSys {
          alias = "desktop1";
          system = "x86_64-linux";
        };

        "${hostnames.desktop1}-installer" = mkNixosSys {
          alias = "desktop1";
          system = "x86_64-linux";
          module = ./nix/installer/desktop1;
        };
        */

        ${hostnames.laptop2} = mkNixosSys {
          alias = "laptop2";
          system = "x86_64-linux";
        };

        "${hostnames.laptop2}-installer" = mkNixosSys {
          alias = "laptop2";
          system = "x86_64-linux";
          module = ./nix/installer/laptop2;
        };

        ${hostnames.rpi1} = mkNixosSys {
          alias = "rpi1";
          system = "aarch64-linux";
        };
      };

      homeConfigurations.${secrets.user_name} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs;
        extraSpecialArgs = {
          inherit cfg secrets dotfiles;
        };
        modules = [ ./nix/home.nix ];
      };

      devShells.${system}.default = nixpkgs.mkShell {
        buildInputs = with nixpkgs; [
          git
          git-crypt
          nixos-generators
          nixos-install-tools
          nixos-option
          nixos-shell
          nixos-rebuild
          nixos-container
          nixpkgs.home-manager # input arg 'home-manager' would be taken otherwise
        ];
        shellHook = ''
          echo -e "" \
          "nixos-rebuild build --flake .#${hostnames.laptop2}[-installer]\n" \
          "home-manager build --flake .#${secrets.user_name}\n" \
          "nix run .#dd-installer -- <hostname> [<block device>]\n" \
          "nixos-generate --flake .#${hostnames.rpi1} --format iso --out-link result\n" \
          "nix build .#nixosConfigurations.${hostnames.rpi1}.config.system.build.sdImage\n" \
          "Hosts: ${builtins.toString secrets.list_of.hostnames}"
        '';
      };

      apps.${system}.dd-installer = {
        type = "app";
        program = ./scripts/build-dd-installer.sh;
      };

      formatter.${system} = nixpkgs.nixfmt-rfc-style;
    };
}
