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
      };
      secrets = import ./nix/secrets.nix { nixpkgs = nixpkgs.legacyPackages.${system}; };
    in
    {
      nixosConfigurations = rec {
        laptop2 = nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = { inherit cfg secrets dotfiles home-manager; };
          modules = [ ./nix/system/laptop2 ];
        };

        laptop2-installer = nixpkgs.lib.nixosSystem {
          inherit system;
          # TODO: populate iso nix store with laptop2's build dependencies
          specialArgs = { inherit secrets; inherit (self) sourceInfo; };
          modules = [ ./nix/installer/laptop2 ];
        };

        # Aliases to map host- and flake target names
        ${secrets.hostnames.laptop2} = laptop2;
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
          echo "nixos-rebuild build --flake .#laptop2";
          echo "home-manager build --flake .#$(grep -P 'user = ' -A 1 nix/secrets.nix | grep -oP '(?<=name = ")\w+(?=")')";
          echo "nix run .#dd-laptop2-installer"
        '';
      };

      apps.${system}.dd-laptop2-installer = {
        type = "app";
        program = "${
          nixpkgs.legacyPackages.${system}.writeShellScript "dd-laptop2.installer.sh" ''
            set -xeuo pipefail

            # nixos-rebuild build --flake .#laptop2
            nixos-generate --flake .#laptop2-installer --format iso --out-link result
            # home-manager build --flake .#"${secrets.user.name}"

            ISO=$(find result/iso/ -iname '*.iso')
            test -f "$ISO"
            test -b /dev/sda

            sudo umount /dev/sda* || true
            sudo dd if="$ISO" of=/dev/sda status=progress conv=fsync
          ''}";
	  };
  };
}
