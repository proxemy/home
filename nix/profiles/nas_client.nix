{ secrets, ... }:
let
  nas_cfg = import ./nas_config.nix;
  mount = {
    source = "${secrets.hostnames.rpi1}:${nas_cfg.root}";
    target = "/import";
    type = "nfs4";
    options = [ "vers=4.2" "noatime" ]; # "noauto
  };
in
{
  fileSystems."${mount.target}" = {
    device = mount.source;
    fsType = mount.type;
    options = mount.options;
  };

  # enables systemd automount
  systemd = {
    mounts = [{
      type = mount.type;
      mountConfig.Options = mount.options;
      what = mount.source;
      where = mount.target;
    }];
    automounts = [{
      wantedBy = [ "multi-user.target" ];
      automountConfig.TimeoutIdleSec = "600";
      where = mount.target;
    }];
  };
}
