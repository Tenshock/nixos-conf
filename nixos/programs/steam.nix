{ pkgs, ... }:
let
  onlineFix = pkgs.writeShellApplication {
    name = "online-fix";
    text = ''
      export WINEDLLOVERRIDES=OnlineFix64,SteamOverlay64,winmm,dnet,steam_api64=n,b
      exec "$@"
    '';
  };
in
{
  environment.systemPackages =
    with pkgs;
    [
      lsfg-vk
      lsfg-vk-ui
      mangohud
    ]
    ++ [ onlineFix ];

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
