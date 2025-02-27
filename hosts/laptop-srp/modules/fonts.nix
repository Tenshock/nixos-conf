{ pkgs, ... }: {
  # depends on hyprland
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];
}



