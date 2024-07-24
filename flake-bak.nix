{
  description = "Base system for raspberry pi 4";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-generators, nixos-hardware, ... }: {
    nixosConfigurations.rpi4-sys = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs = {
            config.allowUnsupportedSystem = true;
            hostPlatform.system = "aarch64-linux";
            buildPlatform.system = "x86_64-linux";
          };
          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
              options = [ "noatime" ];
            };
          };
          users.users.admin = {
            password = "admin";
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
          system.stateVersion = "23.11";
        }
        nixos-hardware.nixosModules.raspberry-pi-4
      ];
    };

    packages.rpi4-sys = {
      sdcard = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        format = "sd-aarch64";
      };
    };
  };
}
