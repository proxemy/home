{
  pkgs,
  lib,
  config,
  self,
  secrets,
  cfg,
  ...
}:
let
  llama_pkg = (
    pkgs.llama-cpp.override {
      cudaSupport = true;
      cpuArchDynamicDispatch = true;
    }
  );

  models = {
    # see:
    # https://wiki.nixos.org/wiki/Llama-cpp#Migration_to_nixos-unstable_(RFC42)
    # https://github.com/ggml-org/llama.cpp/blob/master/docs/preset.md

    "Qwen3.8-27B" = rec {
      alias = "Qwen3.8";
      hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      #hf-file = "Qwen3.8-27B-UD-Q8_K_XL.gguf"; # 31.6GB
      #hf-file = "Qwen3.8-27B-UD-Q6_K.gguf"; # 22 GB
      hf-file = "Qwen3.8-27B-UD-Q5_K_S.gguf"; # 18.7 GB

      n-gpu-layers = 63; # of 64
      n-gpu-layers-draft = 0;

      ctx-size = 84 * 1024;
      reasoning-budget = ctx-size / 4;
      n-predict = ctx-size / 4;
      no-reasoning-preserve = "";

      temperature = 1.0;
      top-k = 20;
      top-p = 0.95;
      min-p = 0.0;
      repeat-penalty = 1.0;
      presence-penalty = 0.0;

      spec-type = "draft-mtp";
      spec-draft-n-max = 2;
      spec-draft-type-k = "q8_0";
      spec-draft-type-v = spec-draft-type-k;
    };

    #"TestModel_SmolLM2" = {
    #  hf-repo = "tensorblock/SmolLM2-135M-Instruct-GGUF";
    #  hf-file = "SmolLM2-135M-Instruct-Q3_K_M.gguf";
    #  #spec-type = "none";
    #};
  };

  cuda_device = "CUDA0";

in
{
  home-manager.users.${secrets.username}.home.packages = [
    llama_pkg
  ];

  services.llama-cpp = {
    enable = true;
    package = llama_pkg;

    settings = rec {
      host = "127.0.0.1";
      port = 8080;

      device = cuda_device;
      threads = 23;
      cache-ram = 24 * 1024;
      #fit-target = cache-ram;
      numa = "numactl";

      flash-attn = "on";
      batch-size = 1024;
      ubatch-size = 256;
      override-tensor = builtins.concatStringsSep "," [
        "token_embd.weight=CPU"
        "per_layer_token_embd=CPU"
      ]; # frees vram
      load-mode = "none";
      rope-scaling = "yarn";
      #kv-unified = "";
      keep = -1;
      context-shift = "";
      #jinja = "";

      reasoning-budget-message = lib.escapeShellArg "Internal reasoning truncated! Compact your relevant progress!";
      offline = "";
      cors-origins = "localhost";
      parallel = 1;
      models-max = 1;
      sleep-idle-seconds = 5 * 60;
      verbosity = if cfg.debug then 3 else 2;

      models-preset = (pkgs.formats.ini { }).generate "llama-models-presets.ini" models;
    };
  };

  systemd.services = {
    llama-cpp = {
      after = [ config.systemd.services.llama-model-loader.name ];
      requires = [ config.systemd.services.llama-model-loader.name ];
      wantedBy = lib.mkForce [ ];

      environment = {
        # DANGEROUS: exceeds ram fast! Beware of too much ctx-size.
        #GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1";

        # https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
        #GGML_CUDA_FORCE_MMQ = "1";
        #GGML_CUDA_FORCE_CUBLAS = "1";
        #GGML_CUDA_FA_ALL_QUANTS = "1";
      };

      serviceConfig = import "${self}/lib/mk_systemd_service.nix" {
        #Restart = false;
        PrivateDevices = false; # required for cuda
        #ProcSubset = lib.mkForce "all";
      };
    };

    llama-model-loader = {
      requires = [ "network-online.target" ];

      unitConfig.RefuseManualStart = true;

      serviceConfig =
        (builtins.removeAttrs config.systemd.services.llama-cpp.serviceConfig [
          "IPAddressDeny"
          "AddressAllow"
          "ExecStart"
          "Restart"
        ])
        // {
          Type = "oneshot";
        };

      script = ''
        cached_models=$(${llama_pkg}/bin/llama-cli --cache-list)
        found_devices=$(${llama_pkg}/bin/llama-cli --list-devices)

        echo "$cached_models"
        echo "$found_devices"

        if ! grep -q "${cuda_device}" <<< "$found_devices"; then
          echo Missing cuda device: ${cuda_device}
          exit 1
        fi

        ${builtins.toString (
          builtins.map (model: ''
            echo checking: ${model.hf-repo} / ${model.hf-file}

            if ! grep -q "${model.hf-repo}" <<< "$cached_models" \
              || [ ! -f "$LLAMA_CACHE"/**/"${model.hf-file}" ] \
            ; then
              echo Missing repo: "${model.hf-repo}"
              echo or missing file: "${model.hf-file}"
              echo downloading ...

              ${llama_pkg}/bin/llama download \
                --hf-repo "${model.hf-repo}" \
                --hf-file "${model.hf-file}"

              echo 'llama download' terminated
            fi
          '') (builtins.attrValues models)
        )}
      '';
    };
  };
}
