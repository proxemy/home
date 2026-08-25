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

    "Qwen3.8" = {
      hf-repo = "unsloth/Qwen3.8-27B-GGUF";
      hf-file = "Qwen3.8-27B-UD-Q8_K_XL.gguf";
    };

    #"TestModel_SmolLM2" = {
    #  hf-repo = "tensorblock/SmolLM2-135M-Instruct-GGUF";
    #  hf-file = "SmolLM2-135M-Instruct-Q3_K_M.gguf";
    #  #spec-type = "none";
    #};
  };

  model_downloads = lib.mapAttrsToList (k: v: {
    repo = v.hf-repo;
    file = v.hf-file;
  }) models;

in
{
  home-manager.users.${secrets.username}.home.packages = [
    llama_pkg
  ];

  services.llama-cpp = {
    enable = true;

    settings = {
      batch-size = 512;
      ctx-size = 252144;
      flash-attn = "on";
      host = "0.0.0.0";
      port = 8080;
      spec-draft-n-max = 2;
      #spec-type = "draft-mtp";
      temp = 0.6;
      top-k = 20;
      top-p = 0.95;
      ubatch-size = 256;

      offline = "";
      verbosity = 0;

      models-preset = (pkgs.formats.ini { }).generate "models-preset.ini" models;
    }
    // lib.optionalAttrs cfg.debug {
      verbosity = 5;
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
        ${llama_pkg}/bin/llama-cli --list-devices
        echo "$cached_models"

        ${builtins.toString (
          builtins.map (model: ''
            if ! grep -q "${model.repo}" <<< "$cached_models" \
              || ! find "$LLAMA_CACHE" -name "${model.file}" \
            ; then
              echo Missing repo: "${model.repo}" or
              echo missing file: "${model.file}"
              echo downloading ...

              ${llama_pkg}/bin/llama download \
                --hf-repo "${model.repo}" \
                --hf-file "${model.file}"

              echo Done.
            fi
          '') model_downloads
        )}
      '';
    };
  };
}
