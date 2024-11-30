{ secrets, ... }:
let
  nfs = {
    ports = [ 2049 ]; # NFSv4 only, TODO: remove legacy 111
    root = "/export"; # TODO: create dedicated and isolated share dir
    options = "(rw,insecure,all_squash)"; # TODO: read only for now
  };
in
{
  # TODO: specify dedicated device (RAID) here
  system.activationScripts.make_export = ''
    mkdir ${nfs.root}
    chmod ugo+rwx ${nfs.root}
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
    # TODO: make it host specific, not for all IPs
    # TODO: authentification/verificytion!
    exports = builtins.toString (
      builtins.map (ip: nfs.root + " " + ip + nfs.options + "\n") secrets.list_of.ips
    );
  };

  networking.firewall.allowedTCPPorts = nfs.ports;
}
