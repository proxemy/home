{
  pkgs,
  lib,
  cfg,
  secrets,
  ...
}:
{
  home-manager.users.${secrets.username}.programs.chromium = {
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
      "--incognito"
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

  nixpkgs.config.allowUnfreePackages = [
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];
}
