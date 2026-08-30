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
      temperature = 1.0;
      top-p = 0.95;
      top-k = 20;
      min-p = 0.0;
      repeat-penalty = 1.0;
      presence-penalty = 0.0;
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
      #model = main_model;

      #n-gpu-layers = "all";
      device = cuda_device;
      #cache-ram = -1;

      #ctx-size = 40 * 1024;
      flash-attn = "on";
      #batch-size = 512;
      #ubatch-size = 256;
      #spec-draft-n-max = 2;
      #spec-type = "draft-mtp";

      #jinja = ""; # OpenAI API, required for goose agent

      offline = "";
      parallel = 1;
      context-shift = "";
      verbosity = if cfg.debug then 5 else 1;

      models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" models;
    };
  };

  systemd.services = {
    llama-cpp = {
      after = [ config.systemd.services.llama-model-loader.name ];
      requires = [ config.systemd.services.llama-model-loader.name ];
      wantedBy = lib.mkForce [ ];

      serviceConfig = import "${self}/lib/mk_systemd_service.nix" {
        PrivateDevices = false; # required for cuda
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

              echo Done.
            fi
          '') (builtins.attrValues models)
        )}
      '';
    };
  };
}
