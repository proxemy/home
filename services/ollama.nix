{
  pkgs,
  lib,
  config,
  ...
}:
let
  user = "ollama";
  #pkg = pkgs.ollama-rocm;
  pkg = pkgs.ollama-vulkan;
in

{
  services = {
    ollama = {
      enable = true;
      inherit user;
      group = user;
      package = pkg;

      loadModels = [
        #"codellama:70b"
        #"deepseek-v3"
        "deepseek-coder:33b"
        "gemma4:31b"
        "qwen3.6:35b"
      ];

      syncModels = true; # adds/removes models according to 'loadModels'
    };

    open-webui = {
      enable = true;
      openFirewall = true;
    };
  };

  nixpkgs.config.allowUnfreePackages = lib.optional config.services.open-webui.enable "open-webui";

  systemd.services = {

    open-webui = rec {
      requiredBy = lib.mkForce [ config.systemd.services.ollama.name ];
      requires = requiredBy;
      serviceConfig = {
        IPAddressDeny = "any";
        IPAddressAllow = "localhost";
        #PrivateNetwork = true;
        PrivateDevices = lib.mkForce true;
        PrivateIPC = true;
        PrivateBPF = true;
      };
    };

    ollama = {
      enable = true;
      #confinement.enable = true;

      serviceConfig = {
        PrivateNetwork = true;
        PrivateDevices = lib.mkForce true;
        PrivateIPC = true;
        PrivateBPF = true;

        # i dont know why these are false by default
        #CanIsolate = true;
        #AllowIsolate = true;
      };

      wantedBy = lib.mkForce [ ]; # disable autostart
    };

    # break dependence of 'multi-user.target' by removal to disable autostart
    ollama-model-loader = rec {
      wantedBy = lib.mkForce [
        config.systemd.services.ollama.name
      ];
      requires = wantedBy;
    };
  };
}
