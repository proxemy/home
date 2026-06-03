{
  config,
  pkgs,
  secrets,
  ...
}:
{
  nixpkgs.config.allowUnfreePackages = [
    "nvidia-x11"
    "nvidia-settings"
    "cuda-merged"
    "libcublas"
    "libcufft"
    "libcurand"
    "libcusolver"
    "libcusparse"
    "libnpp"
    "libnvjitlink"
    "cuda_cccl"
    "cuda_cudart"
    "cuda_cuobjdump"
    "cuda_cupti"
    "cuda_cuxxfilt"
    "cuda_gdb"
    "cuda_nvcc"
    "cuda_nvdisasm"
    "cuda_nvml_dev"
    "cuda_nvprune"
    "cuda_nvrtc"
    "cuda_nvtx"
    "cuda_profiler_api"
    "cuda_sanitizer_api"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    enableRedistributableFirmware = true;

    nvidia = {
      #enabled = true; # implicitly enabled, cant be set multiple times
      open = true;
      gsp.enable = true;
      dynamicBoost.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  # TMP
  users.users.${secrets.username}.packages = with pkgs; [
    nvtopPackages.nvidia
  ];
}
