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
  llama_pkg = (pkgs.llama-cpp.override { cudaSupport = true; });

  models = {
    # see:
    # https://wiki.nixos.org/wiki/Llama-cpp#Migration_to_nixos-unstable_(RFC42)
    # https://github.com/ggml-org/llama.cpp/blob/master/docs/preset.md

    "unsloth/Qwen3.8-27B-GGUF:Q6_K" = {
      alias = "Qwen3.8";
      hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      #hf-file = "Qwen3.8-27B-UD-Q8_K_XL.gguf"; # 31.6GB
      hf-file = "Qwen3.8-27B-UD-Q6_K.gguf"; # 22 GB

      ctx-size = 48 * 1024;
      temperature = 1.0;
      top-p = 0.95;
      top-k = 20;
      min-p = 0.0;
      repeat-penalty = 1.0;
      presence-penalty = 0.0;
      #spec-type = "draft-mtp";
      #spec-draft-n-max = 2;
      #spec-draft-type-k = "q5_0";
      #spec-draft-type-v = "q5_0";
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

    settings = {
      host = "127.0.0.1";
      port = 8080;

      device = cuda_device;
      n-gpu-layers = 999;
      cache-ram = -1;

      flash-attn = "on";
      batch-size = 512;
      ubatch-size = 256;

      jinja = "";
      offline = "";
      parallel = 1;
      #context-shift = "";
      sleep-idle-seconds = 15 * 60;
      verbosity = if cfg.debug then 3 else 2;

      models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" models;
    };
  };

  systemd.services = {
    llama-cpp = {
      after = [ config.systemd.services.llama-model-loader.name ];
      requires = [ config.systemd.services.llama-model-loader.name ];
      wantedBy = lib.mkForce [ ];

      environment = {
        #GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1";

        # https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
        #GGML_CUDA_FORCE_MMQ = "1";
        #GGML_CUDA_FORCE_CUBLAS = "1";
      };

      serviceConfig = import "${self}/lib/mk_systemd_service.nix" {
        PrivateDevices = false; # required for cuda
        #ProcSubset = lib.mkForce "all";
      };
    };

    llama-model-loader = {
      requires = [ "network-online.target" ];

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
            if ! grep -q "${model.hf-repo}" <<< "$cached_models" \
              || ! find "$LLAMA_CACHE" -name "${model.hf-file}" \
            ; then
              echo Missing repo: "${model.hf-repo}" or
              echo missing file: "${model.hf-file}"
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
