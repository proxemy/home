{
  description = "Test flake to build minimum raspeberry image.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixos-hardware.url = "github:nixos/nixos-hardware?ref=kernel-latest";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    {
      nixosConfigurations = {

        laptop2 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # TODO: compilation breaks with there two below, find high value attributes
            # in them an renable them selectively by hand
            #"${nixpkgs}/nixos/modules/profiles/minimal.nix"
            #"${nixpkgs}/nixos/modules/profiles/hardened.nix"
            ./nix/common.nix
            ./nix/laptop2.nix
          ];
        };

        laptop2-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
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

      # naive shell for quick progress
      # TODO: make it 'system' aware
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nixos-generators
          nixos-install-tools
          nixos-option
          nixos-shell
          nixos-rebuild
          nixos-container
          #nixos-anywhere
        ];
      };
    };
}
