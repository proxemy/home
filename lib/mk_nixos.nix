{
  inputs,
  self,
  cfg,
  secrets,
}:
rec {
  mk_nixos =
    {
      host,
      modules ? [ "${self}/systems/${host.alias}" ],
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
        # TODO: remove the host_name arg, its contained in 'host' already
        host_name = secrets.hostnames.${host.alias};
      };
    };

  mk_installer =
    { host }:
    mk_nixos {
      inherit host;
      modules = [
        (import "${self}/systems/installer/medium.nix" { inherit host; })
      ];
    };
}
