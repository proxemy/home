{ secrets, ... }:
let
  nas_cfg = import ./nas_config.nix;
in
{
  # TODO: import some cfg of NAS to replace hard coded pathes
  fileSystems."/import" = {
    device = "${secrets.hostnames.rpi1}:${nas_cfg.root}"; # TODO: dynamic hostname + mount root. not hard coded
    fsType = "nfs4";
    #options = [
    #"nfsvers=4.2"
    #"x-systemd.automount"
    #"noauto"
    #"noatime"
    #];
  };
}
