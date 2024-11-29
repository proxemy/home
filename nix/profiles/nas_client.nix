{ secrets, ... }:
{
  fileSystems."/mnt/nas" = {
    device = "brain:/"; # TODO: dynamic hostnamei + mount root. not hard coded
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
    ];
  };
}
