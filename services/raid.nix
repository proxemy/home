{
  pkgs,
  lib,
  secrets,
  ...
}:
let
  # TODO test and refine this maybe
  mdadm_event_handler = pkgs.writeShellScript "mdadm_event_handler.sh" ''
    echo "$*" | systemd-cat --identifier=mdadm --priority=alert
  '';

  raid = {
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
    automount =
      builtins.replaceStrings [ "/" ] [ "-" ] (builtins.substring 1 99 mount.target) + ".automount";
    nfs-server = "nfs-server.service";
  };
  systemd_service_names_list = builtins.attrValues systemd_service_names;

  # sudo commands for shell aliases and sudoers file
  cmds =
    with lib;
    let
      mdadm = "${getBin pkgs.mdadm}/bin/mdadm";
      cryptsetup = "${getBin pkgs.cryptsetup}/bin/cryptsetup";
      systemctl = "${getBin pkgs.systemd}/bin/systemctl";
      umount = "${getBin pkgs.util-linux}/bin/umount";
    in
    {
      mdadm_detail = "${mdadm} --detail ${mount.source}";
      mdadm_stop = "${mdadm} --stop --verbose ${mount.source}";
      mdadm_asssemble =
        "${mdadm} --assemble --verbose ${mount.source} "
        + builtins.toString (
          builtins.map (num: "/dev/mapper/luks" + num) [
            "1"
            "2"
            "3"
          ]
        );

      cryptsetup_open_1 = "${cryptsetup} luksOpen /dev/sda luks1";
      cryptsetup_open_2 = "${cryptsetup} luksOpen /dev/sdb luks2";
      cryptsetup_open_3 = "${cryptsetup} luksOpen /dev/sdc luks3";
      cryptsetup_close =
        "${cryptsetup} luksClose "
        + builtins.toString [
          "luks1"
          "luks2"
          "luks3"
        ];

      systemctl_stop = "${systemctl} stop ${builtins.toString systemd_service_names_list}";
      systemctl_start = "${systemctl} start ${builtins.toString systemd_service_names_list}";

      umount = "${umount} ${mount.source}";
    };

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

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      hdparm
      pciutils
      sdparm
      smartmontools
      usbutils
    ];

    shellAliases = {
      #dmsetup ls --tree -o blkdevname,uuid
      raid-status = ''
        lsblk -s ${mount.source} -o NAME,SIZE,FSTYPE,FSVER,LABEL,FSAVAIL,FSUSED,MOUNTPOINTS
        sudo ${cmds.mdadm_detail}
        cat /proc/mdstat
      '';

      # TODO maybe chain it together in systemd units and remove nfs stuff here
      raid-stop = ''
        sudo ${cmds.systemctl_stop}
        sudo ${cmds.umount}
        sudo ${cmds.mdadm_stop}
      '';

      raid-start = ''
        sudo ${cmds.mdadm_asssemble}
        sudo ${cmds.systemctl_start}
      '';

      raid-lock = "sudo ${cmds.cryptsetup_close}";

      raid-unlock = ''
        sudo ${cmds.cryptsetup_open_1}
        sudo ${cmds.cryptsetup_open_2}
        sudo ${cmds.cryptsetup_open_3}
      '';

      raid-help = ''
        echo -e " \
        --- format:
        cryptsetup luksFormat --debug --type luks2 --integrity hmac-sha256 /dev/sd-
        --- create:
        mdadm --create --verbose --level 1 --raid-devices=3 /dev/md0 [ /dev/mapper/luks1 <mapped devices> ]
        --- partition & mount:
        mkfs.ext4 -v /dev/md0 && mount /dev/md0 /mnt/raid
        --- Re-add missing drives:
        mdadm --re-add /dev/md0 /dev/mapper/luks1
        "
      '';

      raid-up = ''
        raid-unlock
        raid-start
        raid-status
      '';

      raid-down = ''
        raid-stop
        raid-lock
        raid-status
      '';
    };
  };

  security.sudo.extraRules = [
    {
      users = [ secrets.username ];
      commands = builtins.map (cmd: {
        command = cmd;
        options = [ "NOPASSWD" ];
      }) (builtins.attrValues cmds);
    }
  ];
}
