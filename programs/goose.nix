{
  pkgs,
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

  xdg = config.home-manager.users.${secrets.username}.xdg;
  home = config.users.users.${secrets.username}.home;
  goose_yaml = "${xdg.configHome}/goose/config.yaml";
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
        profile ${goose_pkg}/bin/* {
          ${home}/src/** rw,
          ${home}/**/.git/** r,

          ${xdg.binHome}/** r,
          ${xdg.configHome}/** r,
          ${xdg.stateHome}/goose/** rw,

          deny network,
          deny dbus,
          deny signal,
        }
      '';
    };
}
