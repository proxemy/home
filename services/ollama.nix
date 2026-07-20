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
        #"deepseek-coder:33b"
        "gemma4:31b"
        "qwen3.6:35b"
        #"smollm:135m" # small test model
      ];

      syncModels = true; # adds/removes models according to 'loadModels'
    };

    open-webui = {
      enable = true;
      openFirewall = true;
    };
  };

  nixpkgs.config.allowUnfreePackages = lib.optional config.services.open-webui.enable "open-webui";

  systemd.services =
    let
      hardened_service = {
        IPAddressDeny = "any";
        IPAddressAllow = "localhost";
        PrivateDevices = lib.mkForce true;
        PrivateIPC = true;
        PrivateBPF = true;
        PrivateTmp = true;
        PrivateUsers = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        LockPersonality = true;
      };
    in

    {
      open-webui = {
        requires = [ config.systemd.services.ollama.name ];
        after = [ config.systemd.services.ollama-model-loader.name ];
        wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

        environment = {
          GLOBAL_LOG_LEVEL = if cfg.debug then "DEBUG" else "INFO";
          LOG_LEVEL = if cfg.debug then "DEBUG" else "INFO";
          OFFLINE_MODE = "true";
          RAG_EMBEDDING_ENGINE = "ollama";
          #HF_HUB_OFFLINE = "1";
          #RAG_EMBEDDING_MODEL_AUTO_UPDATE = "false";
          #RAG_RERANKING_MODEL_AUTO_UPDATE = "false";
          #WHISPER_MODEL_AUTO_UPDATE = "false";
          #CORS_ALLOW_ORIGIN = "http://${config.services.open-webui.host}";
        };

        serviceConfig = hardened_service;
      };

      ollama = {
        after = [ config.systemd.services.ollama-model-loader.name ];
        requires = [ config.systemd.services.ollama-model-loader.name ];
        wantedBy = lib.mkForce [ ];

        environment = {
          OLLAMA_NO_CLOUD = "1";
          OLLAMA_NOHISTORY = "1";
          OLLAMA_DEBUG = if cfg.debug then "1" else "0";
        };

        serviceConfig = hardened_service;
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

  /*
    systemd.sockets.open-webui =
      let
        open-webui = config.systemd.services.open-webui;
      in
      {
        description = "Launch ${open-webui.name}";
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = open-webui.port;
          #Accept = false; # pass the port to the service and only start it once.
        };
      };
  */
}
