{
  pkgs,
  lib,
  home-manager,
  config,
  self,
  cfg,
  secrets,
  ...
}:
let
  llama = rec {
    cfg = config.services.llama-cpp;
    host = cfg.settings.host;
    port = builtins.toString cfg.settings.port;
    presets = (import "${self}/lib/read_ini.nix" lib) cfg.settings.models-preset.text;
    model = presets."${goose.conf.GOOSE_MODEL}";
  };

  goose = rec {
    pkg = pkgs.goose-cli;

    hints = ''
      Prime Directives:
      * You are an expert coding assistant running in a restricted environment.
      * Do not try to investigate or fix 'Permission denied' and similar errors.
      * Keep your instructions and reasoning short to spare resources and context window.
      * The $PWD is the project to work on. Don't consider outside directories.
      * You cannot commit to version control.

      Directories you can write to and execute from are:
      ${builtins.toString (builtins.map (d: "${d}**") workdirs)}

      You can use the following tools / packages:
      ${builtins.toString (builtins.map (p: p.meta.mainProgram or p.pname) allowed_tools)}
    '';

    conf = {
      # https://goose-docs.ai/docs/guides/config-files/
      # https://github.com/aaif-goose/goose/blob/main/documentation/docs/guides/config-files.md

      #OPENAI_API_KEY = "no-key"; # secrets in config.yaml are ignored
      OPENAI_HOST = "http://${llama.host}:${llama.port}";
      OPENAI_BASE_PATH = "v1/chat/completions";
      GOOSE_PROVIDER = "openai";
      GOOSE_MODEL = "Qwen3.8-27B"; # sync with llama.models naming

      GOOSE_MODE = "auto"; # "approve";
      #GOOSE_TOOLSHIM = true;
      GOOSE_MAX_TURNS = 200;

      GOOSE_TELEMETRY_ENABLED = false;
      GOOSE_CLI_SHOW_COST = true;
    };

    env_vars = rec {
      # https://goose-docs.ai/docs/guides/environment-variables/

      #GOOSE_TOOLSHIM_BACKEND = "local"; "llama.cpp"; # breaks conn

      # displayed/compacted max context size
      GOOSE_CONTEXT_LIMIT = llama.model.ctx-size;
      GOOSE_AUTO_COMPACT_THRESHOLD = 1.0 - (GOOSE_INPUT_LIMIT * 2) / (GOOSE_CONTEXT_LIMIT + 0.0);
      GOOSE_CONTEXT_STRATEGY = "summary";

      # max model response
      GOOSE_MAX_TOKENS = GOOSE_CONTEXT_LIMIT;

      # "GOOSE_INPUT_LIMIT: Override input token limit for Ollama"
      GOOSE_INPUT_LIMIT = llama.model.reasoning-budget;

      GOOSE_DISABLE_SESSION_NAMING = true;
      GOOSE_RANDOM_THINKING_MESSAGES = false;
      GOOSE_DISABLE_KEYRING = true;
      GOOSE_CLI_THEME = "dark";

      GOOSE_SHELL = "${lib.getExe config.users.users.${secrets.username}.shell}";
      #GOOSE_PATH_ROOT = tmp;

      #GOOSE_SHOW_FULL_OUTPUT = true;
      GOOSE_CLI_MIN_PRIORITY = 0.0; # tool output verbosity: 0.0 = max
      GOOSE_NO_CODE_TRUNCATION = true;
      GOOSE_CLI_SHOW_THINKING = true;
      GOOSE_DEBUG = 1; # show full tool parameters
    };

    cfg = rec {
      dir = "${xdg.configHome}/goose/";
      yaml = "${dir}/config.yaml";
      hints = "${dir}/.goosehints";
    };

    allowed_tools = with pkgs; [
      coreutils
      #util-linux
      binutils
      gnused
      gnugrep
      ripgrep
      gawk
      which
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
      hostname
      coreutils-full
      patchelf
      gcc-unwrapped
      binutils-unwrapped
      config.nix.package.nix-cli
    ];

    workdirs = [
      "${home}/src/"
      tmp
    ];

    tmp = "/tmp/goose/";
  };

  # construct yq compatible filter rule
  yq_filter =
    configs: lib.concatMapAttrsStringSep " | " (k: v: ".${k} = ${builtins.toJSON v}") configs;

  hm_user = config.home-manager.users.${secrets.username};
  xdg = hm_user.xdg;
  home = hm_user.home.homeDirectory;

  # TODO: all these tools should be bundled in a goose-wrapper env
  mk_aa_rules = rules: paths: builtins.foldl' (acc: p: acc + (rules p)) "" paths;
in

{
  home-manager.users.${secrets.username}.home = {
    packages = [ goose.pkg ];

    activation.goose_settings = home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
      run umask 0077
      touch ${goose.cfg.yaml}
      run ${pkgs.yq}/bin/yq -nyi '${yq_filter goose.conf}' ${goose.cfg.yaml}
    '';

    file."${goose.cfg.hints}".source = pkgs.writers.writeText "goose_hints" goose.hints;

    # This alias passes additional env vars to goose, since goose does not
    # respect all 'goose_settings' written in its config.yaml.
    # And it creates writable dirs if missing (like /tmp/goose).
    shellAliases = {
      goose = builtins.toString (
        pkgs.runCommand "goose_wrapper"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          }
          ''
            makeWrapper ${lib.getExe goose.pkg} $out \
              --run ${pkgs.writeShellScript "goose_init.sh" ''
                for wd in ${builtins.toString goose.workdirs}; do
                  [ ! -d "$wd" ] && mkdir -p "$wd" || true
                done
              ''} \
              ${lib.concatMapAttrsStringSep " " (
                k: v:
                "--set-default ${k} ${
                  lib.escapeShellArg (
                    if builtins.isBool v then if v then "true" else "false" else (builtins.toString v)
                  )
                }"
              ) goose.env_vars}
          ''
      );

      goose-log = "tail -f ${xdg.stateHome}/goose/logs/cli/$(date +%Y-%m-%d)/*";
    };
  };

  security.apparmor.policies.goose =
    assert config.security.apparmor.enable;
    {
      state = "enforce";

      profile = ''
        #include <tunables/global>

        profile ${goose.pkg}/bin/* flags=(enforce) {

          # goose
          ${goose.pkg}/bin/* ix,
          owner /var/tmp/etilqs_* rw,
          deny ${home}/.goose/** rwklmx,
          ${xdg.configHome}/goose/** rwk,
          ${xdg.dataHome}/goose/** rwk,
          ${xdg.stateHome}/goose/** rwk,

          deny ${home}/**/{.git,.svn,.hg}/** wklmx,
          audit deny ${home}/**/.env rwklmx,
          deny ${home}/ rwklmx,
          deny ${home}/.bash_history rwklmx,

          ${home}/.rustup/** r,
          ${home}/.cargo/ r,
          ${home}/.cargo/.* rwk,
          ${home}/.cargo/registry/** r,
          /nix/store/*-rust-nightly/bin/* rix,
          /nix/store/*-rust-nightly-complete-with-components-*/bin/* rix,
          /nix/store/*-rustfmt-preview-nightly-complete-*/bin/* rix,

          ${xdg.binHome}/** r,
          ${xdg.configHome}/** r,

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
          ${mk_aa_rules (dir: ''
            ${dir}/ rw,
            ${dir}/** rwixklm,
          '') goose.workdirs}

          # tools and rt deps
          ${mk_aa_rules (p: ''
            ${lib.getBin p}/bin/** ix,
            ${p}/libexec/** ix,
          '') (goose.allowed_tools ++ goose.rt_deps)}

          #nix
          /nix/store/ r,
          /nix/store/** r,
          /nix/store/*/lib/**.so* rm,
          ${xdg.cacheHome}/nix/** rwk,
          / r,

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
          owner /tmp/** wk,
        }
      '';
    };
}
