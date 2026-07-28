{ pkgs, ... }:
{
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    bluetui # bluetooth controller TUI
    ncpamixer # sound mixer TUI
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  services = {
    playerctld.enable = true;
    pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
    };

    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };
}
