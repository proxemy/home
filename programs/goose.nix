{
  pkgs,
  lib,
  home-manager,
  config,
  cfg,
  secrets,
  ...
}:
let
  goose_pkg = pkgs.goose-cli;

  llama = {
    host = config.services.llama-cpp.settings.host;
    port = builtins.toString config.services.llama-cpp.settings.port;
    #model = config.services.llama-cpp.model;
  };

  # construct yq compatible filter rule
  goose_settings = {
    # https://goose-docs.ai/docs/guides/config-files/
    # https://github.com/aaif-goose/goose/blob/main/documentation/docs/guides/config-files.md

    #OPENAI_API_KEY = "no-key"; # secrets in config.yaml are ignored
    OPENAI_HOST = "http://${llama.host}:${llama.port}";
    OPENAI_BASE_PATH = "v1/chat/completions";
    GOOSE_PROVIDER = "openai";
    GOOSE_MODEL = "unsloth/Qwen3.8-27B-GGUF:Q6_K";

    GOOSE_MODE = "auto"; # "approve";
    GOOSE_TOOLSHIM = true;
    GOOSE_MAX_TURNS = 75;

    GOOSE_TELEMETRY_ENABLED = false;
    GOOSE_CLI_SHOW_COST = true;
  };

  # which parameters can be written in the config.yaml and which not is a total mess
  goose_env_vars = rec {
    # https://goose-docs.ai/docs/guides/environment-variables/

    #GOOSE_TOOLSHIM_BACKEND = "llama.cpp"; # breaks conn

    GOOSE_CONTEXT_LIMIT = 48 * 1024 / 2; # sync with model ctx-size
    GOOSE_MAX_TOKENS = GOOSE_CONTEXT_LIMIT / 2;
    GOOSE_INPUT_LIMIT = GOOSE_MAX_TOKENS;
    GOOSE_AUTO_COMPACT_THRESHOLD = 0.7;

    GOOSE_CONTEXT_STRATEGY = "summary";

    GOOSE_DISABLE_SESSION_NAMING = true;
    GOOSE_RANDOM_THINKING_MESSAGES = false;
    GOOSE_NO_CODE_TRUNCATION = false;
    GOOSE_DISABLE_KEYRING = true;
    GOOSE_CLI_THEME = "dark";
  }
  // lib.optionalAttrs cfg.debug {
    GOOSE_DEBUG = 1;
    GOOSE_SHOW_FULL_OUTPUT = true;
    GOOSE_CLI_SHOW_THINKING = true;
    GOOSE_CLI_MIN_PRIORITY = 0.0; # tool output verbosity: 0.0 = max
  };

  goose_settings_yq_filter = lib.concatMapAttrsStringSep " | " (
    k: v: ".${k} = ${builtins.toJSON v}"
  ) goose_settings;

  goose_hints = ''
    Prime Directives:
    * You are an expert coding assistant running in a restricted environment.
    * Do not try to investigate or fix 'Permission denied' and similar errors.
    * The $PWD is the project to work on.
    * You cannot commit to version control.
    * For open web searches, use `ddgr --json "<query>" [-n <max-results>]`.

    Directories you can write to and execute from are:
    ${builtins.toString writable_dirs}

    You can use the following tools / packages:
    ${builtins.toString (builtins.map (p: p.meta.mainProgram or p.pname) allowed_tools)}
  '';

  hm_user = config.home-manager.users.${secrets.username};
  xdg = hm_user.xdg;
  home = hm_user.home.homeDirectory;
  goose_cfg = rec {
    dir = "${xdg.configHome}/goose/";
    yaml = "${dir}/config.yaml";
    hints = "${dir}/.goosehints";
  };

  # TODO: all these tools should be bundled in a goose-wrapper env
  allowed_tools = with pkgs; [
    coreutils
    #util-linux
    binutils
    gnused
    gnugrep
    #ripgrep
    gawk
    which
    hostname
    file
    findutils
    attr
    git
    diffutils
    curl
    wget
    netcat
    iproute2
    iputils
    nmap
    ddgr

    # TODO import profiles/dev.nix packages and remove duplicates below
    python3
    gcc
    cargo
    rust-analyzer
    rustc-unwrapped
    rustfmt
    clippy
    config.nix.package
  ];

  # indirect calls, transitive allowed tools
  rt_deps = with pkgs; [
    bash
    bash-completion
    coreutils-full
    patchelf
    gcc-unwrapped
    binutils-unwrapped
    config.nix.package.nix-cli
  ];

  writable_dirs = [
    "${home}/src/"
    "/tmp/goose/"
  ];

  mk_rules = rules: paths: builtins.foldl' (acc: p: acc + (rules p)) "" paths;
in

{
  home-manager.users.${secrets.username}.home = {
    packages = [ goose_pkg ];

    activation.goose_settings = home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
      run umask 0077
      touch ${goose_cfg.yaml}
      run ${pkgs.yq}/bin/yq -nyi '${goose_settings_yq_filter}' ${goose_cfg.yaml}
    '';

    file."${goose_cfg.hints}".source = pkgs.writers.writeText "goose_hints" goose_hints;

    # goose does not respect all 'goose_settings' in its config.yaml,
    # so pass them as wrapped env vars too. Launched with this alias.
    shellAliases.goose = builtins.toString (
      pkgs.runCommand "goose_wrapper"
        {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        }
        ''
          makeWrapper ${lib.getBin goose_pkg}/bin/goose $out \
            ${lib.concatMapAttrsStringSep " " (
              k: v:
              "--set-default ${k} ${
                lib.escapeShellArg (if builtins.isBool v then if v then "true" else "false" else v)
              }"
            ) goose_env_vars}
        ''
    );
  };

  security.apparmor.policies.goose =
    assert config.security.apparmor.enable;
    {
      state = "enforce";

      profile = ''
        #include <tunables/global>

        profile ${goose_pkg}/bin/* flags=(enforce) {

          # goose
          ${goose_pkg}/bin/* ix,
          owner /var/tmp/etilqs_* rw,

          deny ${home}/**/{.git,.svn,.hg}/** wklmx,
          deny ${home}/ rwklmx,
          deny ${home}/.bash_history rwklmx,

          ${home}/.rustup/** r,
          ${home}/.cargo/ r,
          ${home}/.cargo/.* rwk,
          ${home}/.cargo/registry/** r,

          ${xdg.binHome}/** r,
          ${xdg.configHome}/** r,
          ${xdg.configHome}/goose/** rwk,
          ${xdg.dataHome}/goose/** rwk,
          ${xdg.stateHome}/goose/** rwk,

          #deny network,
          network inet stream,
          network inet6 stream,
          audit deny dbus,
          #audit deny signal,
          signal (send, receive),
          audit deny unix,
          audit deny ptrace,
          audit deny userns,
          audit deny capability
            sys_admin
            sys_ptrace
            sys_rawio
            sys_chroot
            dac_override
            dac_read_search
            setuid
            setgid
          ,

          # write-exec dirs
          ${mk_rules (dir: ''
            ${dir}/ rw,
            ${dir}/** rwixklm,
          '') writable_dirs}

          # tools and rt deps
          ${mk_rules (p: ''
            ${lib.getBin p}/bin/* ix,
            ${p}/libexec/* ix,
          '') (allowed_tools ++ rt_deps)}

          /nix/store/ r,
          /nix/store/** r,
          /nix/store/*/lib/**.so* rm,
          ${xdg.cacheHome}/nix/** rwk,

          @{etc_ro}/ssl/certs/ r,
          @{etc_ro}/ssl/certs/** r,
          @{etc_ro}/pki/tls/certs/ r,
          @{etc_ro}/pki/tls/certs/** r,
          @{etc_ro}/passwd r,
          @{run}/nscd/socket r,
          @{run}/systemd/resolve/stub-resolv.conf r,
          @{sys}/** r,

          @{PROC}/stat r,
          @{PROC}/sys/vm/* r,
          @{PROC}/meminfo r,
          owner @{PROC}/self/** r,
          owner @{PROC}/@{pid}/** r,

          /dev/tty rw,
          owner /dev/pts/** rw,
          /dev/urandom r,
          /dev/null rw,
          /tmp/ r,
          owner /tmp/** rwk,
        }
      '';
    };
}
