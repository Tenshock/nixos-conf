{ lib, pkgs, ... }:
{
  programs.btop = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isLinux then
        pkgs.btop.override {
          cudaSupport = true;
          rocmSupport = true;
        }
      else
        pkgs.btop;
    settings = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      shown_boxes = "cpu mem net proc gpu0 gpu1";
      shown_gpus = "nvidia amd";
      custom_gpu_name0 = "RTX 5070";
      custom_gpu_name1 = "Radeon 890M";
    };
  };
  catppuccin.btop.enable = true;
}
