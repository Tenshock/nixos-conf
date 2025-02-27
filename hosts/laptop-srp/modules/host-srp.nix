{ pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    brightnessctl # enables hotkey brightness control
  ];

  services.logind = {
    extraConfig = ''
      HibernateDelaySec=7200
    '';
  };

  boot.kernelParams = [
    "resume_offset=10536960" # sudo filefrag -v <swapfile> and get first physical offset or filefrag -v /var/lib/swapfile | awk '{if(NR==4) print $4}'
  ];
  boot.resumeDevice = "/dev/nvme0n1p4"; #  stat <swapfile>, get Device id (number, number) && lsblk --output NAME,MAJ:MIN

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024; # in megabytes
  } ];
}
