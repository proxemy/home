{ pkgs, secrets, ... }:
{
  home-manager.users.${secrets.username}.programs.chromium = {
    enable = true;
    package = (pkgs.chromium.override { enableWideVine = true; });
  };

  nixpkgs.config.allowUnfreePackages = [
    "chromium"
    "chromium-unwrapped"
    "widevine-cdm"
  ];
}
