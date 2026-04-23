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
      "gemma4:31b"
      "qwen3.6:35n"
    ];
  };

  # TODO: fix: ollama-model-loader.service cannot download models for a confined ollama.service
  systemd.services.ollama = {
    enable = true;
    confinement.enable = false;
    wantedBy = lib.mkForce [ ];
  };
}
