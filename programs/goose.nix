{
  pkgs,
  lib,
  home-manager,
  config,
  secrets,
  ...
}:
let
  goose_pkg = pkgs.goose-cli;

  # construct yq compatible filter rule
  goose_config = builtins.concatStringsSep " | " (
    builtins.map (e: ".${e}") [
      "OLLAMA_HOST = \"localhost\""
      "OLLAMA_TIMEOUT = 600"
      "GOOSE_PROVIDER = \"ollama\""
      "GOOSE_MODEL = \"qwen3.8:27b\""
      #"GOOSE_TEMPERATURE = 0.7"
      "GOOSE_TELEMETRY_ENABLED = false"
      "GOOSE_MODE = \"approve\""
      "GOOSE_TOOLSHIM = true"
    ]
  );

  hm_user = config.home-manager.users.${secrets.username};
  xdg = hm_user.xdg;
  home = hm_user.home.homeDirectory;
  goose_yaml = "${xdg.configHome}/goose/config.yaml";

  dependencies =
    with pkgs;
    [
      glibc
      gcc-unwrapped
      libgcc
      readline
      ncurses
      acl
      attr

      # from: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/vte.nix
      (pkgs.vte.override {
        withApp = false;
        gtkVersion = null;
      })

    ]
    ++ goose_pkg.buildInputs;

  allowed_tools = with pkgs; [
    goose_pkg
    bash
    bash-completion
    coreutils
    coreutils-full
  ];
in

{
  home-manager.users.${secrets.username} = {
    home.packages = [ goose_pkg ];

    home.activation.goose_config = home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
      run umask 0077
      touch ${goose_yaml}
      run ${pkgs.yq}/bin/yq -nyi '${goose_config}' ${goose_yaml}
    '';
  };

  security.apparmor.policies.goose =
    assert config.security.apparmor.enable;
    {
      state = "enforce";

      profile = ''
        include <tunables/global>

        profile ${goose_pkg}/bin/* {
          ${home}/src/** rw,
          ${home}/**/{.git,.svn,.hg}/** r,
          deny ${home}/.bash_history rwk,

          #${xdg.binHome}/** r,
          #${xdg.configHome}/** r,
          ${xdg.configHome}/goose/** rwk,
          ${xdg.dataHome}/goose/** rwk,
          ${xdg.stateHome}/goose/** rwk,

          #deny network,
          deny dbus,
          deny signal,

          # dependencies
          ${builtins.foldl' (
            acc: dep:
            acc
            + ''
              ${lib.getLib dep}/** rm,
            ''
          ) "" dependencies}

          # tools
          ${builtins.foldl' (
            acc: tool:
            acc
            + ''
              ${lib.getBin tool}/bin/* rix,
              ${tool}/** r,
            ''
          ) "" allowed_tools}

          # data
          ${config.i18n.glibcLocales}/** r,
          ${config.environment.etc.profile.source} r,
          ${config.environment.etc.bashrc.source} r,
          ${config.environment.etc."profiles/per-user/${secrets.username}".source}/** r,
          ${config.home-manager.users."${secrets.username}".home.file.".profile".source} r,
          ${config.system.path}/** r,
          ${hm_user.home.file.".bash_profile".source} r,
          ${pkgs.tzdata}/** r,
          ${pkgs.cacert}/** r,

          # TODO: find package of gmp-with-cxx and remove broad /nix/store access
          /nix/store/*-gmp-with-cxx-*/lib/** rm,
          /nix/store/** r,

          /etc/ssl/certs/ r,
          /etc/ssl/certs/** r,
          /etc/pki/tls/certs/ r,
          /etc/pki/tls/certs/** r,
          /dev/tty rw,
          /dev/pts/** rw,
          /dev/urandom r,
          /dev/null rw,
          /sys/devices/system/cpu/** r,
          /sys/fs/cgroup/user.slice/** r,
          /proc/stat r,
          /proc/self/** r,
          /proc/@{pid}/** r,
          /tmp/** wr,
        }
      '';
    };
}
