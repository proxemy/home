{
  pkgs,
  lib,
  secrets,
  ...
}:
let
  arkenfox = rec {
    userjs = builtins.readFile "${pkgs.arkenfox-userjs}/user.js";
    split = builtins.split "\nuser_pref\\(([^)]+)" userjs;
    flatten = lib.lists.flatten (builtins.filter builtins.isList split);
    filter = builtins.filter (line: !lib.strings.hasPrefix "\"_user.js" line) flatten;
    attrs =
      let
        split_pair = line: builtins.split ",[[:space:]]+" line;
        remove_quotes = str: lib.strings.replaceString "\"" "" str;
        attr_name = line: (remove_quotes (lib.lists.head (split_pair line)));
        attr_value = line: (remove_quotes (lib.lists.last (split_pair line)));
      in
      lib.attrsets.genAttrs' filter (line: lib.nameValuePair (attr_name line) (attr_value line));
  };

  arkenfox_overrides = {
    "security.OCSP.enabled" = 0;
    "security.OCSP.require" = false;
  };

  # see 'https://wiki.debian.org/Firefox#Disabling_automatic_connections'
  disable_telemetry = {
    "app.update.enabled" = false;
    "app.update.auto" = false;
    "app.update.url.details" = "";
    "app.update.url.manual" = "";
    "browser.search.update" = false;
    "extensions.update.enabled" = false;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.server" = "";
    "toolkit.telemetry.unified" = false;
  };

  custom_settings =
    let
      #dns_server = "ns.quad9.net/dns-query";
      dns_server = "https://doh.securedns.eu/dns-query";
    in
    {
      "browser.casting.enabled" = false;
      "browser.download.folderList" = 2;
      "browser.download.forbid_open_with" = true;
      "browser.fixup.alternate.enabled" = false; # Dont fix typed URLs with eg 'www' prefix. for urlbar search keys
      "browser.translations.enable" = false;
      "browser.uitour.url" = "";
      "browser.urlbar.suggest.history" = false;
      "browser.urlbar.suggest.openpage" = false;
      "browser.urlbar.suggest.topsites" = false;
      "dom.popup_allowed_events" = "click dblclick mousedown pointerdown";
      "extensions.autoDisableScopes" = 15;
      "extensions.formautofill.addresses.enabled" = false;
      "extensions.formautofill.creditCards.enabled" = false;
      "keyword.enabled" = true; # Enable keyword search in the urlbar.
      "layout.css.visited_links_enabled" = false;
      "media.gmp-gmpopenh264.enabled" = false;
      "media.gmp-provider.enabled" = false;
      "media.peerconnection.ice.no_host" = true;
      "network.proxy.allow_bypass" = false;
      "etwork.http.sendRefererHeader" = 0;
      "network.trr.custom_uri" = dns_server;
      "network.trr.uri" = dns_server;
      "network.trr.default_provider_uri" = dns_server;
      "network.trr.mode" = 3;
      "permissions.default.shortcuts" = 2;
      "places.history.enabled" = false;
      "privacy.fingerprintingProtection.remoteOverrides.enabled" = false;
      "privacy.resistFingerprinting.randomization.daily_reset.enabled" = true;
      "privacy.resistFingerprinting.randomization.daily_reset.private.enabled" = true;
      "privacy.trackingprotection.enabled" = true;
      "security.mixed_content.block_display_content" = true;
      "signon.rememberSignons" = false;

      # dark theme
      "ui.systemUsesDarkTheme" = 1;
      "layout.css.prefers-color-scheme.content-override" = 0;
      "extensions.activeThemeID" = "default-theme@mozilla.org";

      # https://www.theregister.com/2024/06/18/mozilla_buys_anonym_betting_privacy/
      "dom.private-attribution.submission.enabled" = "false";
    };
in
#TODO: incorporate https://github.com/pyllyukko/user.js
{
  home-manager.users.${secrets.username}.programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = arkenfox.attrs // arkenfox_overrides // disable_telemetry // custom_settings;

      bookmarks = {
        enable = true;
        force = true;
        settings = with secrets.bookmarks; to_name_url_list firefox;
      };

      search = {
        force = true;
        default = "ddg";
        order = [
          "ddg"
          "google"
        ];
      };
    };

    policies = {
      # From: https://wiki.nixos.org/wiki/Firefox
      # Updates & Background Services
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      Cookies = "AllowSession";
      NetworkPrediction = false;

      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      SanitizeOnShutdown = {
        Cache = true;
        Cookies = true;
        Downloads = true;
        FormData = true;
        History = true;
        Sessions = true;
        SiteSettings = true;
        OfflineApps = true;
        Locked = true;
      };

      # Feature Disabling
      #DisableBuiltinPDFViewer       = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      #DisableFirefoxScreenshots     = true;
      #DisableForgetButton           = true;
      DisableMasterPasswordCreation = true;
      DisableProfileImport = true;
      DisableProfileRefresh = true;
      DisableSetDesktopBackground = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;

      # Access Restrictions
      BlockAboutConfig = false;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;

      # UI and Behavior
      DisplayMenuBar = "never";
      DontCheckDefaultBrowser = true;
      #HardwareAcceleration          = false;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      DefaultDownloadDirectory = "~/Downloads";
      #NoDefaultBookmarks = true;

      # Bookmarks
      DisplayBookmarksToolbar = "newtab";
      # TODO: fix malformed bookmarks
      #ManagedBookmarks = secrets.bookmarks.firefox;

      # Extension
      ExtensionSettings =
        let
          mozilla = addon: "https://addons.mozilla.org/firefox/downloads/latest/${addon}/latest.xpi";
        in
        {
          # blocks all addons except the ones specified below
          "*".installation_mode = "blocked";

          "uMatrix@raymondhill.net" = {
            install_url = mozilla "uMatrix";
            installation_mode = "force_installed";
            default_area = "navbar";
            private_browsing = true;
            updates_disabled = true;
          };

          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = mozilla "privacy-badger17";
            installation_mode = "force_installed";
            private_browsing = true;
            updates_disabled = true;
          };
        };

      "3rdparty".Extensions = {
        "uMatrix@raymondhill.net".adminSettings = {
          userSettings = {
            uiTheme = "dark";
            autoUpdate = true;
            cloudStorageEnabled = false;
            externalList = secrets.umatrix_rules;
          };
        };
      };
    };
  };
}
