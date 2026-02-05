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
      system,
      modules ? [ ./../system/${host.alias} ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules;
      #nixpkgs.hostPlatform = system;
      specialArgs = {
        inherit (self) sourceInfo;
        inherit (inputs) dotfiles home-manager;
        inherit
          cfg
          secrets
          host
          ;
        # TODO: remove the host_name arg, its contained in 'host' already
        host_name = secrets.hostnames.${host.alias};
      };
    };

  mk_installer =
    { host, system }:
    mk_nixos {
      inherit host system;
      modules = [
        (import ../system/installer/medium.nix { inherit host; })
      ];
    };
}
