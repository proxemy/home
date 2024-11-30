{ secrets, ... }:
{
  # TODO: import some cfg of NAS to replace hard coded pathes
  fileSystems."/export" = {
    device = "${secrets.hostnames.rpi1}:/export"; # TODO: dynamic hostname + mount root. not hard coded
    fsType = "nfs4";
    #options = [
      #"nfsvers=4.2"
      #"x-systemd.automount"
      #"noauto"
    #];
  };
}
