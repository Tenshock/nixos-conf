{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lsfg-vk
    lsfg-vk-ui
    mangohud
  ];

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
