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
    { self, nixpkgs, home-manager, dotfiles, ... }:
    let
      system = "x86_64-linux";
      cfg = {
        stateVersion = "24.11";
        homeDir = "/etc/nixos/home";
      };
      secrets = import ./nix/secrets.nix { nixpkgs = nixpkgs.legacyPackages.${system}; };
    in
    {
      nixosConfigurations = rec {
        ${secrets.hostnames.laptop2} = nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit cfg secrets dotfiles home-manager; };
          modules = [ ./nix/system/laptop2 ];
        };

        "${secrets.hostnames.laptop2}-installer" = nixpkgs.lib.nixosSystem {
          inherit system;
          # TODO: populate iso nix store with laptop2's build dependencies
          specialArgs = { inherit cfg secrets; inherit (self) sourceInfo; };
          modules = [ ./nix/installer/laptop2 ];
        };
      };

      homeConfigurations.${secrets.user.name} =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.outputs.legacyPackages.${system};
        extraSpecialArgs = { inherit cfg secrets dotfiles; };
        modules = [ ./nix/home.nix ];
      };

      # naive shell for quick progress
      # TODO: make it 'system' aware
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          git git-crypt
          nixos-generators
          nixos-install-tools
          nixos-option
          nixos-shell
          nixos-rebuild
          nixos-container

          nixpkgs.outputs.legacyPackages.${system}.home-manager
        ];
        shellHook = ''
          echo "nixos-rebuild build --flake .#${secrets.hostnames.laptop2}[-installer]";
          echo "home-manager build --flake .#${secrets.user.name}";
          echo "nix run .#dd-installer -- <hostname> [<block device>]"
        '';
      };

      apps.${system}.dd-installer = {
        type = "app";
        program = ./scripts/build-dd-installer.sh;
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}
