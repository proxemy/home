{ secrets, ... }:
{
  services.llama-cpp = {
    enable = true;

    modelsPreset = {
      # Requires 8GB VRAM 
      "LFM2.5-8B-A1B" = {
        hf-repo = "unsloth/LFM2.5-8B-A1B-GGUF";
        hf-file = "LFM2.5-8B-A1B-UD-Q4_K_XL.gguf";
        alias = "unsloth/LFM2.5-8B-A1B-GGUF";
        temp = "0.2";
        repeat-penalty = "1.05";
        top-k = "80";
      };
  };

}
