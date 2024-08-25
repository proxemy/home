{
  description = "Test flake to build minimum raspeberry image.";

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
      cfg = {
        stateVersion = "24.11";
        username = "leme";
      };
      secrets = import ./nix/secrets.nix { inherit nixpkgs; };
    in
    {
      nixosConfigurations = {
        laptop2 = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = { inherit cfg secrets dotfiles; };
          modules = [
            "${nixpkgs}/nixos/modules/profiles/hardened.nix"
            ./nix/common.nix
            ./nix/laptop2.nix

            home-manager.nixosModule {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.leme = import ./nix/home.nix specialArgs;
              };
            }
          ];
        };

        laptop2-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit cfg secrets;
            inherit (self) sourceInfo;
            # TODO: populate iso nix store with laptop2's build dependencies
            #laptop2 = self.outputs.nixosConfigurations.laptop2;
          };
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
            ./nix/common.nix
            ./nix/laptop2-installer.nix
          ];
        };
      };

      homeConfigurations.leme = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.outputs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit cfg dotfiles; };
        modules = [ ./nix/home.nix ];
      };

      # naive shell for quick progress
      # TODO: make it 'system' aware
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          git git-crypt
          nixos-generators
          nixos-install-tools
          nixos-option
          nixos-shell
          nixos-rebuild
          nixos-container
          #nixos-anywhere

          nixpkgs.outputs.legacyPackages.x86_64-linux.home-manager
        ];
        shellHook = ''
			echo "nixos-rebuild build --flake .#laptop2";
			echo "home-manager build --flake .#leme";
		'';
      };
  };
}
