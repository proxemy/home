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

  llama = {
    host = config.services.llama-cpp.settings.host;
    port = builtins.toString config.services.llama-cpp.settings.port;
    #model = config.services.llama-cpp.model;
  };

  # construct yq compatible filter rule
  goose_settings = builtins.concatStringsSep " | " (
    builtins.map (e: ".${e}") [
      "OPENAI_API_KEY = \"no-key\""
      "OPENAI_HOST = \"http://${llama.host}:${llama.port}\""
      "OPENAI_BASE_PATH = \"v1/chat/completions\""
      "GOOSE_PROVIDER = \"openai\""
      "GOOSE_MODEL = \"unsloth/Qwen3.8-27B-GGUF:Q6_K\""

      #"OLLAMA_HOST = \"localhost\""
      #"OLLAMA_TIMEOUT = 600"
      #"GOOSE_PROVIDER = \"ollama\""
      #"GOOSE_MODEL = \"qwen3.8:27b\""
      #"GOOSE_TEMPERATURE = 0.7"
      "GOOSE_TELEMETRY_ENABLED = false"
      "GOOSE_MODE = \"auto\"" # \"approve\""
      "GOOSE_TOOLSHIM = true"
      "GOOSE_MAX_TURNS =  5000"
      #"GOOSE_CLI_MIN_PRIORITY = 0.0" # tool output verbosity: 0.0 = max
      #"GOOSE_SHOW_FULL_OUTPUT = true" # show full cli command invocations
      #"GOOSE_NO_CODE_TRUNCATION = true"
      "GOOSE_TERMINAL = true"
      #"AGENT = \"goose\""
    ]
  );

  goose_hints = ''
    You are an expert coding assistant running in a restricted environment.
    Do not try to work around ‘permissions denied’ and similar errors.
    You cannot commit to version control.
    You do have access to the Internet.

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

  allowed_tools = with pkgs; [
    bash
    bash-completion
    coreutils
    coreutils-full
    util-linux
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

  writable_dirs = [
    "${home}/src/"
    "/tmp/goose/"
  ];
in

{
  home-manager.users.${secrets.username}.home = {
    packages = [ goose_pkg ];

    activation.goose_settings = home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
      run umask 0077
      touch ${goose_cfg.yaml}
      run ${pkgs.yq}/bin/yq -nyi '${goose_settings}' ${goose_cfg.yaml}
    '';

    file."${goose_cfg.hints}".source = pkgs.writers.writeText "goose_hints" goose_hints;
  };

  security.apparmor.policies.goose =
    assert config.security.apparmor.enable;
    {
      state = "enforce";

      profile = ''
        #include <tunables/global>

        profile ${goose_pkg}/bin/* {

          ${goose_pkg}/bin/* ix,

          deny ${home}/**/{.git,.svn,.hg}/** wxkm,
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

          # write-exec dirs
          ${builtins.foldl' (
            acc: dir:
            acc
            + ''
              ${dir}/ rw,
              ${dir}/** rwix,
            ''
          ) "" writable_dirs}


          # tools
          ${builtins.foldl' (
            acc: tool:
            acc
            + ''
              ${lib.getBin tool}/bin/* ix,
            ''
          ) "" allowed_tools}

          /nix/store/ r,
          /nix/store/** r,
          /nix/store/*/lib/**.so* rm,

          @{etc_ro}/ssl/certs/ r,
          @{etc_ro}/ssl/certs/** r,
          @{etc_ro}/pki/tls/certs/ r,
          @{etc_ro}/pki/tls/certs/** r,
          @{run}/nscd/socket r,
          @{run}/systemd/resolve/stub-resolv.conf r,
          @{sys}/devices/system/cpu/** r,
          @{sys}/fs/cgroup/user.slice/** r,

          @{PROC}/stat r,
          @{PROC}/sys/vm/* r,
          owner @{PROC}/self/** r,
          owner @{PROC}/@{pid}/** r,

          /dev/tty rw,
          owner /dev/pts/** rw,
          /dev/urandom r,
          /dev/null rw,
          /tmp/ r,
          owner /tmp/** rwk,

          deny /etc/passwd rwxkm,
        }
      '';
    };
}
