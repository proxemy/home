{
  pkgs,
  lib,
  config,
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
    "privacy.resistFingerprinting.letterboxing" = false;
  };

  custom_settings =
    let
      #dns_server = "ns.quad9.net/dns-query";
      #dns_server = "https://doh.securedns.eu/dns-query";
      dns_server = "https://doh.ffmuc.net/dns-query";
    in
    {
      # Disable telemetry
      # see 'https://wiki.debian.org/Firefox#Disabling_automatic_connections'
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
      #"extensions.autoDisableScopes" = 15;
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
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      "privacy.resistFingerprinting" = false; # sadly, this need to be, otherwise prefers-color-scheme is inaccessible for websites
      # https://superuser.com/questions/1610744/how-do-i-get-around-resistfingerprinting-setting-my-preferred-firefox-theme-to-l
      "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme";

      # https://www.theregister.com/2024/06/18/mozilla_buys_anonym_betting_privacy/
      "dom.private-attribution.submission.enabled" = "false";

      # newtab stuff
      # disable newtab shortcuts/suggestions
      "browser.newtabpage.activity-stream.feeds.topsites" = false;
      "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
      "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
      "browser.newtabpage.activity-stream.showSearch" = false;
      "browser.newtabpage.activity-stream.asrouter.devtoolsEnabled" = true;
    };

  ff_cfg = config.home-manager.users.${secrets.username}.programs.firefox;

in
#TODO: incorporate https://github.com/pyllyukko/user.js
{
  home-manager.users.${secrets.username} = {

    home.file =
      let
        profiles = ff_cfg.profilesPath;
        profile = ff_cfg.profiles.default.path;
      in
      {
        # overwrite HMs creation of extensions sub dirs.
        # see https://github.com/nix-community/home-manager/blob/3ee51fbdac8c8bdfe1e7e1fcaba6520a563f394f/modules/programs/firefox/mkFirefoxModule.nix#L53
        "${profiles}/${profile}/extensions".source = lib.mkForce (
          pkgs.buildEnv {
            name = "my_firefox_extensions";
            paths = ff_cfg.profiles.default.extensions.packages;
          }
        );
      };

    programs.firefox = {
      enable = true;

      profiles.default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings =
          import ./mozilla_prefs.nix { inherit lib; }
          // arkenfox.attrs
          // arkenfox_overrides
          // custom_settings;

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

        extensions = {
          force = true;
          #exactPermissions = true;

          packages =
            let
              fetch_addon =
                # addonId must match mozillas GUID (https://addons.mozilla.org/api/v5/addons/addon/${name})
                # or firefox silently rejects the extension (maybe warn in logs, see CTRL+SHIFT+J)
                name: addonId: sha256:
                pkgs.stdenv.mkDerivation {
                  inherit name addonId;
                  meta.mozPermissions =
                    config.home-manager.users.${secrets.username}.programs.firefox.profiles.default.extensions.settings.${addonId}.permissions
                      or [ ];
                  src = builtins.fetchurl {
                    inherit name sha256;
                    url = "https://addons.mozilla.org/firefox/downloads/latest/${name}/latest.xpi";
                  };
                  buildCommand = ''install -D "$src" "$out"/"${addonId}".xpi'';
                };

            in
            [
              (fetch_addon "uMatrix" "uMatrix@raymondhill.net"
                "sha256-HeFysdgt4owzSDT3sOrs4LUD9Z5iz8DM8jIiuPLLiOU="
              )
              (fetch_addon "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack"
                "sha256-7qSfFGHeXrAOsXsisoZLVbVKy1d7A2BodGD+mCYz+9Y="
              )
            ];

          settings = {
            "uMatrix@raymondhill.net" = {
              force = true;
              # extension permissions should match its manifest.json listed permissions
              permissions = [
                "browsingData"
                "cookies"
                "privacy"
                "storage"
                "tabs"
                "webNavigation"
                "webRequest"
                "webRequestBlocking"
                "<all_urls>"
              ];
              settings.userMatrix = secrets.umatrix_rules;
            };

            #"jid1-MnnxcxisBPnSXQ@jetpack" = { };
          };
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
      };
    };

    # set default browser
    xdg.mimeApps =
      let
        #ff = "org.mozilla.firefox.desktop";
        ff = "firefox.desktop";

        mime_types = [
          "application/x-extension-htm"
          "application/x-extension-html"
          "application/x-extension-shtml"
          "application/x-extension-xht"
          "application/x-extension-xhtml"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/about"
          "x-scheme-handler/chrome"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/unknown"
        ];
      in
      {
        enable = true;
        defaultApplications = lib.attrsets.genAttrs mime_types (mime_type: ff);
        associations.added = lib.attrsets.genAttrs mime_types (mime_type: ff);
      };

    home.sessionVariables =
      let
        ff_exec = "${lib.getBin ff_cfg.package}/bin/firefox";
      in
      {
        BROWSER = ff_exec;
        DEFAULT_BROWSER = ff_exec;
      };
  };
}
