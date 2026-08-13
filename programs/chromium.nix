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
  _preferences = builtins.toJSON (
    {
      enable_do_not_track = true;
      privacy_sandbox.first_party_sets_enabled = false;
      profile.default_content_setting_values.javascript_optimizer = 2;
      profile.cookie_controls_mode = 1;
      net.network_prediction_options = 2;
    }
    // {
      profile.content_settings.exceptions.cookies = lib.genAttrs' secrets.bookmarks.allowed_cookies (
        url:
        (lib.nameValuePair "*,${url}" {
          last_modified = 0;
          setting = 1;
        })
      );
    }
  );

  preferences = builtins.toFile "chromium_preferences" _preferences;

in
{
  home-manager.users.${secrets.username} = {
    programs.chromium = {
      enable = true;
      package = (pkgs.chromium.override { enableWideVine = true; });

      commandLineArgs = [
        "--block-new-web-contents"
        "--disable-background-mode"
        "--disable-background-networking"
        "--disable-client-side-phishing-detection"
        "--disable-component-update"
        "--disable-default-apps"
        "--disable-domain-reliability"
        #"--disable-features=Prerender2"
        "--disable-file-system"
        #"--incognito"
        "--isolation-by-default"
        "--no-pings"
        "--process-per-site"
        "--site-per-process"
      ]
      ++ lib.optionals cfg.debug [
        "--enable-logging=stderr"
        "--v=2"
      ];
    };

    home.activation.chromium_preferences =
      let
        xdg = config.home-manager.users.${secrets.username}.xdg;
      in
      home-manager.lib.hm.dag.entryAfter [ "writeBoudnary" ] ''
        run umask 0077
        run cat "${preferences}" > "${xdg.configHome}/chromium/Default/Preferences"
      '';
  };

  nixpkgs.config.allowUnfreePackages = [
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];
}
