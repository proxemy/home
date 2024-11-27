{ secrets, ... }:
let
  nfs_port = 2049;
in
{
  services.nfs.server = {
    enable = true;
    exports = ''
      TODO
    '';
  };

  networking.firewall.allowedTCPPorts = [ nfs_port ];
}
