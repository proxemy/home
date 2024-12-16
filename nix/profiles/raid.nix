{ pkgs, ... }:
let
  mdadm_event_handler = pkgs.writeShellScript "mdadm_event_handler.sh" ''
    #!{pkgs.bash}/bin/bash
    echo $* | systemd-cat --identifier=mdadm --priority=alert
  '';

  mount = {
    source = "/dev/md0";
    target = "/mnt/raid";
    type = "ext4";
    options = [
      "rw"
      "noatime"
      "nosuid"
      "nodev"
      "noexec"
    ];
  };

in
# format:
# cryptsetup luksFormat --debug --type luks2 --integrity hmac-sha256 /dev/sd-
# open:
# cryptsetup luksOpen /dev/sd- <mapped device name>
# create:
# mdadm --create --verbose --level 1 --raid-devices=4 /dev/md0 [/dev/mapper/<mapped devices> ]
# partition & mound:
# mkfs.ext4 -v /dev/md0 && mount /dev/md0 /mnt/raid
# stop:
# umount /dev/md0 && mdadm --stop /dev/md0
# dump config for /etc/mdadm.conf:
# mdadm --detail --scan --verbose
{
  boot = {
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY /dev/md0 level=raid1 num-devices=4 metadata=1.2 UUID=bdc3d424:76660866:61370f67:d73e849a
        PROGRAM ${mdadm_event_handler}
      '';
    };

    kernelModules = [
      "md_mod"
      "raid1"
      "dm_crypt"
      "dm_integrity"
      "dm_bufio"
    ];
  };

  systemd = {
    mounts = [
      {
        type = mount.type;
        mountConfig.Options = mount.options;
        what = mount.source;
        where = mount.target;
      }
    ];
    automounts = [
      {
        wantedBy = [ "multi-user.target" ];
        where = mount.target;
      }
    ];
  };
}
