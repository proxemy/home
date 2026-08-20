{
  pkgs,
  lib,
  config,
  self,
  cfg,
  secrets,
  ...
}:
let
  user = "ollama";
  pkg = pkgs.ollama-cuda;
  #pkg = pkgs.ollama-vulkan;
in

{
  services.ollama = {
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

  nixpkgs.config.allowUnfreePackages = lib.optional config.services.open-webui.enable "open-webui";

  systemd.services = {
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

      serviceConfig = (
        import "${self}/lib/mk_systemd_service.nix" {
          ProtectHome = lib.mkForce "read-only"; # true
          PrivateDevices = false; # required for cuda
        }
      );
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
}
