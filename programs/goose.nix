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
      "GOOSE_MODE = \"auto\"" # \"approve\""
      "GOOSE_TOOLSHIM = true"
      "GOOSE_MAX_TURNS =  5000"
      #"GOOSE_CLI_MIN_PRIORITY = 0.0" # tool output verbosity: 0.0 = max
      #"GOOSE_SHOW_FULL_OUTPUT = true" # show full cli command invocations
      #"GOOSE_NO_CODE_TRUNCATION = true"
      #"GOOSE_TERMINAL = true"
      #"AGENT = \"goose\""
    ]
  );

  hm_user = config.home-manager.users.${secrets.username};
  xdg = hm_user.xdg;
  home = hm_user.home.homeDirectory;
  goose_yaml = "${xdg.configHome}/goose/config.yaml";

  allowed_tools = with pkgs; [
    goose_pkg
    bash
    bash-completion
    coreutils
    coreutils-full
    gnused
    gnugrep
    gawk
    which
    file
    findutils
    attr
    git
    curl
    wget
    netcat
    iproute2
    iputils
    nmap

    python3
    cargo
    config.nix.package
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
        #include <tunables/global>

        profile ${goose_pkg}/bin/* {
          ${home}/src/** rw,
          ${home}/src/ rw,
          ${home}/**/{.git,.svn,.hg}/** r,
          deny ${home}/ rwxkm,
          deny ${home}/.bash_history rwxkm,

          ${xdg.binHome}/** r,
          ${xdg.configHome}/** r,
          ${xdg.configHome}/goose/** rwk,
          ${xdg.dataHome}/goose/** rwk,
          ${xdg.stateHome}/goose/** rwk,

          #deny network,
          network inet,
          network inet6,
          deny dbus,
          deny signal,

          # tools
          ${builtins.foldl' (
            acc: tool:
            acc
            + ''
              ${lib.getBin tool}/bin/* ix,
            ''
          ) "" allowed_tools}

          /nix/store/** r,
          /nix/store/*/lib/**.so* rm,

          @{etc_ro}/ssl/certs/ r,
          @{etc_ro}/ssl/certs/** r,
          @{etc_ro}/pki/tls/certs/ r,
          @{etc_ro}/pki/tls/certs/** r,
          @{run}/nscd/socket r,
          @{sys}/devices/system/cpu/** r,
          @{sys}/fs/cgroup/user.slice/** r,

          @{PROC}/stat r,
          @{PROC}/sys/vm/* r,
          owner @{PROC}/self/** r,
          owner @{PROC}/@{pid}/** r,

          /dev/tty rw,
          /dev/pts/** rw,
          /dev/urandom r,
          /dev/null rw,
          /tmp/ r,
          owner /tmp/** wr,

          deny /etc/passwd rwxkm,
        }
      '';
    };
}
