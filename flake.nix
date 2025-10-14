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
        home_git_dir = "/etc/nixos/home";
        supported_systems = [
          "aarch64-linux"
          #"armv7l-linux"
          "x86_64-linux"
        ];
      };
      secrets = import ./nix/secrets { inherit pkgs; };
      inherit (secrets) hostnames;

      forSystems = nixpkgs.lib.genAttrs cfg.supportedSystems;
      system = "x86_64-linux"; # builtins.currentSystem;
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      inherit (import ./nix/lib/mkNixos.nix {
        inherit
          inputs
          self
          cfg
          secrets
          ;
      }) mkNixos mkInstaller;
    in
    {
      nixosConfigurations = {

        ${hostnames.desktop1} = mkNixos {
          alias = "desktop1";
          system = "x86_64-linux";
        };

        "${hostnames.desktop1}-installer" = mkInstaller {
          alias = "desktop1";
          system = "x86_64-linux";
        };

        ${hostnames.laptop1} = mkNixos {
          alias = "laptop1";
          system = "x86_64-linux";
        };

        "${hostnames.laptop1}-installer" = mkInstaller {
          alias = "laptop1";
          system = "x86_64-linux";
        };

        ${hostnames.laptop2} = mkNixos {
          alias = "laptop2";
          system = "x86_64-linux";
        };

        "${hostnames.laptop2}-installer" = mkInstaller {
          alias = "laptop2";
          system = "x86_64-linux";
        };

        ${hostnames.rpi1} = mkNixos {
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
        program = "${./scripts/build-dd-installer.sh}";
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
