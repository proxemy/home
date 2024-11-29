{ secrets, ... }:
let
  nfs = {
    port = 2049; # NFSv4 only
    root = "/"; # TODO: create dedicated and isolated share dir
    options = "(r)"; # TODO: read only for now
  };
in
{
  # TODO: specify dedicated device (RAID) here
  /*
    fileSystems."/export" = {
      device = "TODO: by-label?";
      options = [ "bind" ];
    };
  */

  services.nfs.server = {
    enable = true;
    # TODO: make it host specific, not for all IPs
    # TODO: authentification/verificytion!
    exports = builtins.toString (
      builtins.map (ip: "\n" + nfs.root + " " + ip + nfs.options) secrets.list_of.ips
    );
  };

  networking.firewall.allowedTCPPorts = [ nfs.port ];
}
