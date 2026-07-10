{
  pkgs,
  lib,
  config,
  cfg,
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

    open-webui = {
      requires = [ config.systemd.services.ollama.name ];
      wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

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
      environment = {
        OLLAMA_NO_CLOUD = "1";
        OLLAMA_NOHISTORY = "1";
        OLLAMA_DEBUG = if cfg.debug then "1" else "0";
      };

      serviceConfig = {
        IPAddressDeny = "any";
        IPAddressAllow = "localhost";
        #PrivateNetwork = true;
        PrivateDevices = lib.mkForce true;
        PrivateIPC = true;
        PrivateBPF = true;

        # i dont know why these are false by default
        #CanIsolate = true;
        #AllowIsolate = true;
      };

      after = [ config.systemd.services.ollama-model-loader.name ];
      requires = [ config.systemd.services.ollama-model-loader.name ];
      wantedBy = lib.mkForce [ ]; # disable autostart
    };

    ollama-model-loader = {
      # custom launch behavior allows downloading of models while the main
      # ollama.service has only access to localhosts network.

      after = lib.mkForce [ "network-online.target" ];
      bindsTo = lib.mkForce [ ];
      wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

      preStart = "${lib.getBin config.services.ollama.package}/bin/ollama serve & sleep 5";

      serviceConfig =
        (builtins.removeAttrs config.systemd.services.ollama.serviceConfig [
          "IPAddressDeny"
          "AddressAllow"
          "ExecStart"
          "Restart"
        ])
        // {
          Type = lib.mkForce "oneshot";
        };
    };
  };

  systemd.sockets.open-webui =
    let
      open-webui = config.systemd.services.open-webui;
    in
    {
      description = "Launches ${open-webui.name} (ollama)";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = 8080;
        Accept = false; # pass the port to the service and only start it once.
      };
    };
}
