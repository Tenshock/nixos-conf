{ pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      cudaSupport = true;
      rocmSupport = true;
    };
    settings = {
      shown_boxes = "cpu mem net proc gpu0 gpu1";
      shown_gpus = "nvidia amd";
      custom_gpu_name0 = "RTX 5070";
      custom_gpu_name1 = "Radeon 890M";
    };
  };
  catppuccin.btop.enable = true;
}
