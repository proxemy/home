{
  pkgs,
  lib,
  config,
  cfg,
  secrets,
  ...
}:
let
  user = "ollama";
  pkg = pkgs.ollama-cuda;
  #pkg = pkgs.ollama-vulkan;
  #systemd = config.systemd.package;
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
        "qwen3.8:27b"

        #"all-minilm:latest"
        "nomic-embed-text:latest"
        #"mxbai-embed-large:latest"

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
        IPAddressAllow = "localhost"; # TODO: only allow certain local IPC ports
        LockPersonality = true;
        MemoryDenyWriteExecute = lib.mkForce true;
        NoNewPrivileges = true;
        PrivateBPF = true;
        #PrivateDevices = lib.mkForce true; # required for cuda
        PrivateIPC = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectControlGroups = true;
        ProtectHome = lib.mkForce "read-only"; # true
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    in

    {
      open-webui = {
        requires = [ config.systemd.services.ollama.name ];
        after = [ config.systemd.services.ollama-model-loader.name ];
        wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

        environment = {
          GLOBAL_LOG_LEVEL = if cfg.debug then "INFO" else "ERROR";
          LOG_LEVEL = if cfg.debug then "INFO" else "ERROR";
          FFLINE_MODE = "True";
          HF_HUB_OFFLINE = "True";

          RAG_EMBEDDING_ENGINE = "ollama";
          RAG_EMBEDDING_MODEL = "nomic-embed-text"; # "all-minilm"; "nomic-embed-text"; "mxbai-embed-large";
          RAG_EMBEDDING_MODEL_AUTO_UPDATE = "False";
          RAG_RERANKING_MODEL_AUTO_UPDATE = "False";
          WHISPER_MODEL_AUTO_UPDATE = "False";

          #CORS_ALLOW_ORIGIN = "http://${config.services.open-webui.host}";

          WEBUI_ADMIN_EMAIL = "${secrets.username}@a.b";
          WEBUI_ADMIN_PASSWORD = secrets.username;
          WEBUI_ADMIN_NAME = secrets.username;
          ENABLE_SIGNUP = "False";

          ENABLE_KB_EXEC = "True";
          ENABLE_CALENDAR = "False";
          ENABLE_CHANNELS = "False";
          ENABLE_AUTOMATIONS = "False";
          ENABLE_SUBAGENTS = "False";
          ENABLE_EASTER_EGGS = "False";

          USE_CUDA = "True";
          DEVICE_TYPE = "cuda";
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

          #OLLAMA_CONTEXT_LENGTH = 0;
          #OLLAMA_FLASH_ATTENTION = "1";

          OLLAMA_VERBOSE = if cfg.debug then "1" else "0";
          OLLAMA_DEBUG = if cfg.debug then "1" else "0";
          OLLAMA_DEBUG_LOG_REQUESTS = if cfg.debug then "1" else "0";
        };

        serviceConfig = hardened_service;
      };

      ollama-model-loader =
        # models must contain a ':<tag>' definition for path lookup below, use ':latest' if missing
        assert builtins.all (m: (builtins.match "(.+:.+)" m != null)) config.services.ollama.loadModels;
        let
          ollama = "${lib.getBin config.services.ollama.package}/bin/ollama";
          models = config.services.ollama.loadModels;
          library = "${config.services.ollama.home}/models/manifests/registry.ollama.ai/library";
        in
        {
          # custom launch behavior allows downloading of models while the main
          # ollama.service has only access to localhosts network.

          after = lib.mkForce [ "network-online.target" ];
          bindsTo = lib.mkForce [ ];
          wantedBy = lib.mkForce [ ]; # remove multi-user.target to disable autostart

          preStart = ''
            all_models_found=true

            for model in ${builtins.toString models}; do
              if [ ! -f "${library}"/"''${model/":"/"/"}" ]; then
                echo Missing model: "$model"
                all_models_found=false
              fi
            done

            if $all_models_found; then
              echo No models to download
            else
              echo Starting ollama to download models
              ${ollama} serve &
              sleep 5s
            fi
          '';

          environment = lib.mkForce config.systemd.services.ollama.environment;

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

          unitConfig = {
            ConditionPathExists = builtins.map (
              model: builtins.replaceStrings [ ":" ] [ "/" ] "|!${library}/${model}"
            ) models;
          };
        };
    };

  systemd.sockets.open-webui =
    let
      open-webui = config.services.open-webui;
    in
    {
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        # open-webui is not trivially able the take over a connection fd
        # tries to bind to 8080 directly.
        ListenStream = open-webui.port + 1;
        Accept = false;
        #BindToDevice = "lo";
        IPAllow = [ "127.0.0.1" ] ++ secrets.list_of.ips;
        IPDeny = "any";
      };
    };
}
