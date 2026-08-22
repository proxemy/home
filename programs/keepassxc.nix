{
  cfg,
  secrets,
  pkgs,
  self,
  config,
  ...
}:
let
  kp_secrets = import "${self}/secrets/keepassxc.nix" secrets;
  keepassxc = "${pkgs.keepassxc}/bin/keepassxc";
  user = secrets.username;
  group = "keepassxc";
  unit = "keepassxc-run0";
  systemd = config.systemd.package;
  xdg = config.home-manager.users.${user}.xdg;
  home = config.users.users.${user}.home;
  cmd = ''
    ${systemd}/bin/run0 \
      --user="${user}" \
      --group="${group}" \
      --unit="${unit}" \
      --description="keepassxc-run0 command wrapper" \
      --setenv=DISPLAY="$DISPLAY" \
      --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
      ${keepassxc}
  '';
in
{
  users.users.${user}.packages = [
    pkgs.keepassxc
    #pkgs.apparmor-parser
  ];

  # TODO:
  # * S/GUID(?) for keepassxc exec with own 'keepassxc' owner/group
  # * above file ownership for vault, token, cache, tmp(?)
  # * check service for vault, token, cache, tmp(?)
  # * make the *.so rm permissions more dependency selective

  security.apparmor.policies.keepassxc =
    assert config.security.apparmor.enable;
    {
      state = "enforce";

      profile = ''
        profile ${pkgs.keepassxc}/bin/keepassxc {
          ${home}/${kp_secrets.vault} rw,
          ${home}/${kp_secrets.vault}.* rwl,
          ${home}/${kp_secrets.token} r,

          ${xdg.configHome}/keepassxc/keepassxc.ini rw,
          ${xdg.cacheHome}/keepassxc/** rwkl,
          ${xdg.configHome}/fontconfig/conf.d/ r,
          ${xdg.cacheHome}/fontconfig/** r,
          ${xdg.dataHome}/** r,
          ${home}/.Xauthority r,
          ${home}/#[0-9]* rw,
          /run/user/1000/ICEauthority r,
          /tmp/keepassxc-${user}.lock rwk,

          ${keepassxc} r,
          ${pkgs.keepassxc}/bin/.keepassxc-wrapped ix,

          /nix/store/**.so* rm,
          /nix/store/** r,

          deny network,
          deny dbus,
          deny signal,

          ${
            if cfg.debug then
              ""
            else
              ''
                # silence verbose logging
                deny /proc/** rwklm,
                deny /dev/** rwklm,
                deny /sys/** rwklm,
                deny /tmp/** rwklm,
              ''
          }
        }
      '';
    };
  /*
    systemd.user.services.keepassxc = {
      serviceConfig = {
        ExecStart = "${keepassxc}";
        Group = group;
      };
    };

    security.polkit.extraConfig =
      assert config.security.polkit.enable;
      ''
        # Allow ${user} to run keepassxc without password prompt
        polkit.addRule(function(action, subject) {
          if (subject.user === "${user}") {
            polkit.log(action.toString());
            polkit.log(subject.toString());
            #return polkit.Result.YES;
          }
        })
      '';

    users.groups.${group} = {
      name = group;
      members = [ ];
    };
  */
}
#${pkgs.libc}/lib/libc.so* rm,
#${pkgs.qrencode.out}/lib/*.so* rm,
#${pkgs.qt5.qtsvg}/lib/*.so* rm,
#${pkgs.qt5.qtbase.out}/lib/libQt5*.so* rm,
#${pkgs.qt5.qtx11extras}/lib/libQt5X11Extras.so* rm,
#${pkgs.pcsclite.lib}/lib/libpcsclite.so* rm,
#${pkgs.libargon2}/lib/libargon2.so* rm,
#${pkgs.botan3.out}/lib/libbotan-3.so* rm,
#${pkgs.zlib}/lib/libz.so* rm,
#${pkgs.minizip}/lib/libminizip.so* rm,
#${pkgs.libusb1}/lib/libusb-1.0.so* rm,
#${pkgs.libx11}/lib/libX11.so* rm,
#${pkgs.gccForLibs.lib}/lib/libstdc++.so* rm,
#${pkgs.glibc}/lib/libm.so* rm,
#${pkgs.libgcc}/lib/libgcc_s.so* rm,
#${pkgs.libglvnd}/lib/libGL.so* rm,
