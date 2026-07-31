{
  pkgs,
  lib,
  config,
  self,
  secrets,
  ...
}:
let
  devices = import "${self}/secrets/raid_devices.nix" lib;

  # TODO test and refine this maybe
  mdadm_event_handler = pkgs.writeShellScript "mdadm_event_handler.sh" ''
    ${lib.getBin pkgs.systemd}/bin/systemd-cat --identifier=mdadm --priority=alert ${lib.getBin pkgs.coreutils-full}/bin/printf "$*"
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
    let
      mdadm = "${lib.getBin pkgs.mdadm}/bin/mdadm";
      cryptsetup = "${lib.getBin pkgs.cryptsetup}/bin/cryptsetup";
      systemctl = "${lib.getBin pkgs.systemd}/bin/systemctl";
      umount = "${lib.getBin pkgs.util-linux}/bin/umount";

    in
    {
      mdadm_detail = "${mdadm} --detail --test --prefer=by-uuid ${mount.source}";
      mdadm_stop = "${mdadm} --stop --verbose ${mount.source}";
      mdadm_asssemble = # --scan --no-degraded
        "${mdadm} --assemble --verbose ${mount.source} "
        + builtins.toString (builtins.map (id: "/dev/mapper/${id}") devices.ids);
      mdadm_check = "${mdadm} --misc --action=check ${mount.source}";

      systemctl_stop = "${systemctl} stop ${builtins.toString systemd_service_names_list}";
      systemctl_start = "${systemctl} start ${builtins.toString systemd_service_names_list}";

      umount = "${umount} ${mount.source}";

      cryptsetup_close = "${cryptsetup} luksClose " + (builtins.toString devices.ids);
    }
    //
      # cryptsetup_open_[0..n]
      builtins.listToAttrs (
        lib.imap (i: id: {
          name = "cryptsetup_open_${builtins.toString i}";
          value = "${cryptsetup} luksOpen /dev/disk/by-id/${id} ${id}";
        }) devices.ids
      );

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

    services.raid-repair = {
      description = "RAID repair";

      conflicts = [ config.systemd.services.nixos-upgrade.name ];

      path = with pkgs; [
        mdadm
        gnugrep
        coreutils-full
      ];

      serviceConfig.Type = "simple";

      # TODO: unmount raid and e2fsck
      script = "mdadm --verbose --wait --misc --action=repair ${mount.source}";
    };
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
        lsblk -s ${mount.source} -o NAME,SIZE,FSTYPE,FSVER,LABEL,MOUNTPOINTS,MODEL,SERIAL
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

      raid-unlock =
        let
          cmd = i: cmds."cryptsetup_open_${i}";
        in
        builtins.toString (builtins.map (i: "sudo ${cmd i}\n") devices.range);

      raid-check = "sudo ${cmds.mdadm_check}";

      raid-help = ''
        echo -e " \
        Format new device:
          cryptsetup luksFormat --debug --type luks2 --integrity hmac-sha256 /dev/sd_

        Create raid:
          mdadm --create --verbose --level 1 --raid-devices=3 /dev/md0 [ /dev/mapper/luks1 <mapped devices> ]

        Re-add missing drives:
          mdadm --re-add /dev/md0 /dev/mapper/luks1

        Start degraded/partial raid:
          # forcefully --run
          mdadm --assemble --run /dev/md0 [ /dev/mapper/luks1, ]
          # ignore bad block log, to force a stale assembly
          mdadm --assemble /dev/md0 --update=force-no-bbl [ /dev/mapper/luks1, ]

        Check/Repair (scrub):
          mdadm --misc --action=[check/repair/frozen] /dev/md0
          echo check | sudo tee /sys/block/md0/md/sync_action
          dmsetup staus / info <dm-device>

        Docs:
          https://docs.kernel.org/admin-guide/device-mapper/dm-raid.html
          https://www.man7.org/linux/man-pages/man8/mdadm.8.html
          https://www.man7.org/linux/man-pages/man4/md.4.html
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

      raid-aliases = ''
        alias raid-unlock
        echo
        alias raid-start
        echo
        alias raid-stop
        echo
        alias raid-lock
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
