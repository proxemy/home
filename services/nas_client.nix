{ secrets, ... }:
let
  nas_cfg = import ./nas_config.nix;
  mount = {
    source = "${secrets.hostnames.rpi1}:${nas_cfg.root}";
    target = "/import";
    type = "nfs4";
    options = [
      "vers=4.2"
      "noatime"
      "nosuid"
      "nodev"
      "noexec"
    ];
  };
in
{
  # to manually mount the nfs share, use:
  # mount.nfs4 <mount.source> <mount.target>

  # xfce thunar bookmark. maybe older gtk versions are used ...
  home-manager.users.ddder =
    let
      file_url = "file://${mount.target}";
    in
    {
      gtk.gtk3.bookmarks = [ file_url ];
      # TMP: manual workaround for disrespected gtk setting above
      xdg.configFile."gtk-3.0/bookmarks" = {
        text = file_url;
      };
    };

  fileSystems."${mount.target}" = {
    device = mount.source;
    fsType = mount.type;
    options = mount.options;
  };

  # enables systemd automount
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
        automountConfig.TimeoutIdleSec = "600";
        where = mount.target;
      }
    ];
  };
}
