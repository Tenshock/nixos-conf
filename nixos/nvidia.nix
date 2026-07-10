{ config, ... }: {
  services.xserver.videoDrivers = [
    "amdgpu"
    "nvidia"
  ];

  hardware = {
    graphics.enable = true;

    nvidia = {
      open = true;
      modesetting.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
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
