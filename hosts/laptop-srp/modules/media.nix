
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    bluetui   # bluetooth controller TUI
    ncpamixer # sound TUI mixer
  ];

  # audio
  services.playerctld.enable = true;
  hardware.bluetooth.enable = true;

  # audio controller
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
  };
}
