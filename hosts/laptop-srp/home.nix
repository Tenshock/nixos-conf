let
  hosts = import ../hosts.nix;
in
{
  imports = [
    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix

    ../../home/flavors/hyprland.nix
  ];
  home.packages = [];

  home = {
    username = hosts.laptop-srp.user;
    homeDirectory = "/home/${hosts.laptop-srp.user}";
    stateVersion = "24.11";
  };

  ### HOME
  # firefox
  # obsidian
  # dotnet-sdk_9
  # csharpier -> nixvim
  # webcord
  # appimage-run -> nix flake for Beeper beta?
  # fonts
  # kitty
  # full hyprland
  # neovim -> nixvim
  # wget
  # git
  # go
  # eza
  # bat
  # zoxide
  # fastfetch
  # btop
  # cava
  # cbonsai
  # yazi
  # zsh
  # tmux
  # virtualization
  #   k9s
  # ~/.local/bin
  #

  ### NixOS
  # login-manager
  # nix.nix

  ### hosts
  # host-networking
  # host-srp -> swap
  # i18n -> split in hosts/keyboard and home/i18n
  # media

}
