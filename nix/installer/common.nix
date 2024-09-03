{
  pkgs,
  cfg,
  hostName,
  ...
}:
{
  environment = {
    systemPackages = with pkgs; [
      git
      git-crypt
    ];
    shellAliases.home-install = "sudo -E bash /iso/install.sh ${cfg.homeDir}";
  };

  networking.hostName = hostName;

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
