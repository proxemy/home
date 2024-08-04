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
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
            "${nixpkgs}/nixos/modules/profiles/clone-config.nix"
            # TODO reactivate hardened kernel and fix missing ext4 support in live-nixos
            #"${nixpkgs}/nixos/modules/profiles/hardened.nix"
            ./nix/common.nix
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
          nixos-anywhere
        ];
      };
    };
}
