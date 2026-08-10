{ config, pkgs, ... }:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.latest;
  nvidiaIcd = "${nvidiaPackage}/share/vulkan/icd.d/nvidia_icd.json";
  nvidiaIcd32 = "${nvidiaPackage.lib32}/share/vulkan/icd.d/nvidia_icd.json";

  NvidiaVulkan = pkgs.writeShellApplication {
    name = "nvidia-vulkan";
    text = ''
      export VK_DRIVER_FILES="${nvidiaIcd}:${nvidiaIcd32}"
      export VK_ICD_FILENAMES="$VK_DRIVER_FILES"

      exec "$@"
    '';
  };
in
{
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  environment.systemPackages = [
    NvidiaVulkan
    pkgs.nvtopPackages.nvidia
  ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = nvidiaPackage;
      nvidiaPersistenced = false;

      powerManagement = {
        enable = false;
        finegrained = false;
      };

      prime = {
        allowExternalGpu = true;

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        amdgpuBusId = "PCI:193@0:0:0";
        nvidiaBusId = "PCI:98@0:0:0";
      };
    };
  };
}
