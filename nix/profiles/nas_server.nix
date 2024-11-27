{ secrets, ... }:
let
  nfs_port = 2049; # NFSv4 only
  client_options = "";
in
{
  fileSystems."/export" = {
    device = "TODO";
    options = [ "bind" ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /export
      TODO
    '';
  };

  networking.firewall.allowedTCPPorts = [ nfs_port ];
}
