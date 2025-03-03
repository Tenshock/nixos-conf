let
  hosts = import ../hosts.nix;
in {
  imports = [
    ../../home/features/application/firefox.nix
    ../../home/features/application/obsidian.nix

    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix
    ../../home/features/cli/yazi.nix
    ../../home/features/cli/zoxide.nix
    ../../home/features/cli/zsh.nix

    ../../home/features/fonts/nerd.nix

    ../../home/features/service/srp-vpn.nix

    ../../home/flavors/hyprland.nix
  ];

  home = {
    username = hosts.laptop-srp.user;
    homeDirectory = "/home/${hosts.laptop-srp.user}";
    stateVersion = "24.11";
  };

  ### HOME
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
  # fastfetch
  # cbonsai
  # yazi
  # tmux
  # virtualization
  #   k9s
  # ~/.local/bin
  #

  ### hosts
  # host-networking
  # i18n -> split in hosts/keyboard and home/i18n
  # media

}
