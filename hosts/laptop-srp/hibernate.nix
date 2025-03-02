{
  boot = {
    resumeDevice = "/dev/nvme0n1p4"; #  stat <swapfile>, get Device id (number, number) && lsblk --output NAME,MAJ:MIN
    kernelParams = [
      "resume_offset=10536960" # sudo filefrag -v <swapfile> and get first physical offset or filefrag -v /var/lib/swapfile | awk '{if(NR==4) print $4}'
    ];
  };

  services.logind = {
    extraConfig = ''
      HibernateDelaySec=7200
    '';
  };
}
