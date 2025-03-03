let
  hosts = import ../hosts.nix;
in {
  imports = [
    ../../home/features/application/firefox.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/obsidian.nix

    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix
    ../../home/features/cli/cbonsai.nix
    ../../home/features/cli/eza.nix
    ../../home/features/cli/fastfetch.nix
    ../../home/features/cli/git.nix
    ../../home/features/cli/tmux.nix
    ../../home/features/cli/yazi.nix
    ../../home/features/cli/zoxide.nix
    ../../home/features/cli/zsh.nix

    ../../home/features/fonts/nerd.nix

    ../../home/features/service/srp-vpn.nix
    ../../home/features/service/xdg.nix

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
  # full hyprland
  # neovim -> nixvim
  # wget
  # go
  # fastfetch
  # cbonsai
  # tmux
}
