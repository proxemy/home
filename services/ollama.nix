{ pkgs, lib, ... }:
let
  user = "ollama";
  #pkg = pkgs.ollama-rocm;
  pkg = pkgs.ollama-vulkan;
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
      "qwen3.6:35b"
    ];
  };

  # TODO: fix: ollama-model-loader.service cannot download models for a confined ollama.service
  systemd.services.ollama = {
    enable = false;
    confinement.enable = true;
  };
}
