{
  inputs,
  self,
  cfg,
  secrets,
}:

let
  nixos_system =
    {
      host,
      modules,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit modules;
      specialArgs = {
        inherit (inputs) dotfiles home-manager;
        inherit
          self
          cfg
          secrets
          host
          ;
      };
    };
in

{
  inherit nixos_system;

  mk_nixos =
    host:
    nixos_system {
      inherit host;
      modules = [ "${self}/systems/${host.alias}" ];
    };

  mk_installer =
    host:
    nixos_system {
      inherit host;
      modules = [
        (import "${self}/systems/installer/medium.nix" { inherit host; })
      ];
    };
}
