{ pkgs, ... }:
let
  mdadm_event_handler = pkgs.writeShellScript "mdadm_event_handler.sh" ''
    #!{pkgs.bash}/bin/bash
    echo $* | systemd-cat --identifier=mdadm --priority=alert
  '';
in
{
  boot = {
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY /dev/md/0 level=raid1 num-devices=3 metadata=1.2 UUID=c07219cf:4e1bca0c:8d3e245f:204b8044
        devices=/dev/sda,/dev/sdb,/dev/sdc
        PROGRAM ${mdadm_event_handler}
      '';
    };

    kernelModules = [ "md_mod" "raid1" ];
  };
}
