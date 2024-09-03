{ pkgs, cfg, ... }:
{
  environment = {
    systemPackages = with pkgs; [
      git
      git-crypt
    ];
    variables = {
      HOMEDIR = cfg.homeDir;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    settings.system-features = [
      "nix-command"
      "flakes"
      "big-parallel"
      "kvm"
    ];
  };

  #isoImage.storeContents = [ sourceInfo ];
}
