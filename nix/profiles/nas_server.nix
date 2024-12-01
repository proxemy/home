{ secrets, ... }:
let
  nas_cfg = import ./nas_config.nix;
in
{
  # TODO: specify dedicated device (RAID) here
  system.activationScripts.make_export = ''
    mkdir ${nas_cfg.root}
    chmod ugo+rwx ${nas_cfg.root}
  '';
  /*
    fileSystems."/export" = {
      device = "TODO: by-label?";
      fsType = "nfs4";
      options = [ "bind" ];
    };
  */

  services.nfs.server = {
    enable = true;
    extraNfsdConfig = ''
      UDP=off
      vers3=off
      vers4.0=false
      vers4.1=false
      vers4.2=true
      vers4=true
    '';
    # TODO: make it host specific, not for all IPs
    # TODO: authentification/verificytion!
    exports = builtins.toString (
      builtins.map (ip: nas_cfg.root + " " + ip + nas_cfg.options + "\n") secrets.list_of.ips
    );
  };

  networking.firewall.allowedTCPPorts = nas_cfg.ports;
}
