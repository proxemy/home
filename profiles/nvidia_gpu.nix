{
  config,
  pkgs,
  secrets,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    enableRedistributableFirmware = true;

    nvidia = {
      #enabled = true; # implicitly enabled
      open = true;
      gsp.enable = true;
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  # TMP
  users.users.${secrets.username}.packages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
