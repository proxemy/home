{
  inputs,
  self,
  cfg,
  secrets,
}:
rec {
  mkNixos =
    {
      alias,
      system,
      modules ? [ ./../system/${alias} ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system modules;
      specialArgs = {
        inherit (self) sourceInfo;
        inherit (inputs) dotfiles home-manager;
        inherit
          cfg
          secrets
          ;
        host_name = secrets.hostnames.${alias};
      };
    };

  mkInstaller =
    { alias, system }:
    mkNixos {
      inherit alias system;
      modules = [
        (import ../system/installer/medium.nix { inherit alias; })
      ];
    };
}
