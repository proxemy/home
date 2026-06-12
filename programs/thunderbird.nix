{ lib, secrets, ... }:
{
  home-manager.users.${secrets.username} = {
    home.file.".thunderbird/default/user.js".force = true;

    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;

        settings = import ./mozilla_prefs.nix { inherit lib; } // {
          "mail.spellcheck.inline" = false;
          "extensions.activeThemeID" = "thunderbird-compact-dark@mozilla.org";

          "javascript.enabled" = false;
          "network.protocol-handler.warn-external.http" = true;
          "network.protocol-handler.warn-external.https" = true;
          "privacy.resistFingerprinting" = true;
          "mail.sanitize_date_header" = true;

          "mail.threadpane.listview" = 1;
          "mail.pane_config.dynamic" = 0;

          "mailnews.display.prefer_plaintext" = true;
          "mailnews.start_page.enabled" = false;
          "mailnews.start_page.url" = "";

          "plain_text.wrap_long_lines" = true;

          "network.proxy.socks" = secrets.tor_proxy.ip;
          "network.proxy.socks_port" = secrets.tor_proxy.socks_port;
          "network.proxy.allow_bypass" = false;

          "browser.search.suggest.enabled" = false;
          "browser.search.update" = false;
        };
      };
    };
  };
}
