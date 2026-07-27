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
  home = config.users.users.${secrets.username}.home;
in
{
  users.users.${secrets.username}.packages = [
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

          ${home}/.config/keepassxc/keepassxc.ini rw,
          ${home}/.config/fontconfig/conf.d/ r,
          ${home}/.cache/keepassxc/** rwkl,
          ${home}/.cache/fontconfig/** r,
          ${home}/.local/share/** r,
          ${home}/.Xauthority r,
          ${home}/#[0-9]* rw,
          /run/user/1000/ICEauthority r,
          /tmp/keepassxc-${secrets.username}.lock rwk,

          ${pkgs.keepassxc}/bin/keepassxc r,
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
                deny /dev/ rwklm,
                deny /sys/** rwklm,
                deny /tmp/** rwklm,
              ''
          }
        }
      '';
    };
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
