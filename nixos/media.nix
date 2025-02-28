{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bluetui   # bluetooth controller TUI
    ncpamixer # sound mixer TUI
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # audio controllers
  services.playerctld.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
  };
}
