{ pkgs, lib, ... }:
let
  # TODO test and refine this maybe
  mdadm_event_handler = pkgs.writeShellScript "mdadm_event_handler.sh" ''
    #!{pkgs.bash}/bin/bash
    echo $* | systemd-cat --identifier=mdadm --priority=alert
  '';

  raid = rec {
    level = "raid1";
    num-devices = "3";
    auto = "no";
    metadata = "1.2";
    UUID = "00bac42a:49843f7f:2933c7e8:84ace931";
  };
  raid_config_str = builtins.toString (lib.mapAttrsToList (n: v: n + "=" + v) raid);

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

  systemd_service_names = {
    automout =
      builtins.replaceStrings [ "/" ] [ "-" ] (builtins.substring 1 99 mount.target) + ".automount";
    nfs-server = "nfs-server.service";
  };
  systemd_service_names_list = builtins.attrValues systemd_service_names;
in
{
  boot = {
    swraid = {
      enable = true;
      mdadmConf = ''
        ARRAY <ignore> ${raid_config_str}
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

  environment.shellAliases = {
    raid-status = ''
      echo "--- lsblk:"
      lsblk -fs ${mount.source}
      echo "--- dmsetup:"
      dmsetup ls --tree -o blkdevname,uuid
      echo "--- mdadm status:"
      mdadm --detail ${mount.source}
      echo "--- mdadm config:"
      mdadm --monitor --verbose --scan
    '';
    # TODO maybe chain it together in systemd units and remove nfs stuff here
    raid-stop = ''
      systemctl stop ${builtins.toString systemd_service_names_list}
      umount ${mount.source}
      mdadm --stop --verbose ${mount.source}
    '';
    raid-start = ''
      mdadm --assemble --verbose ${mount.source} /dev/mapper/luks{1,2,3}
      mount ${mount.source}
      systemctl start ${builtins.toString systemd_service_names_list}
    '';
    raid-restart = "raid-stop; raid-start";
    raid-lock = ''
      raid-stop
      cryptsetup luksClose luks1
      cryptsetup luksClose luks2
      cryptsetup luksClose luks3
    '';
    raid-unlock = ''
      cryptsetup luksOpen /dev/sda luks1
      cryptsetup luksOpen /dev/sdb luks2
      cryptsetup luksOpen /dev/sdc luks3
    '';
    raid-help = ''
      echo -e "" \
      "--- format:\n" \
      "cryptsetup luksFormat --debug --type luks2 --integrity hmac-sha256 /dev/sd-\n" \
      "--- create:\n" \
      "mdadm --create --verbose --level 1 --raid-devices=4 /dev/md0 [ /dev/mapper/luks1 <mapped devices> ]\n" \
      "--- partition & mount:\n" \
      "mkfs.ext4 -v /dev/md0 && mount /dev/md0 /mnt/raid\n" \
      "--- TODO: how to integrate new devices
    '';
  };
}
