let
  hosts = import ../hosts.nix;
in {
  imports = [
    ../../home/features/application/firefox.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/teams.nix

    ../../home/features/service/srp-vpn.nix

    ../../home/flavors/minimal.nix
    ../../home/flavors/hyprland.nix
  ];

  home = {
    username = hosts.laptop-srp.user;
    homeDirectory = "/home/${hosts.laptop-srp.user}";
    stateVersion = "24.11";
  };

  ### HOME
  # dotnet-sdk_9
  # csharpier -> nixvim
  # neovim -> nixvim
  # go
}
