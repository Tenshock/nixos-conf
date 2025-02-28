{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    kitty
    wofi          # app launcher
    wl-clipboard  # clipboard manager
    waybar        # status bar
    hyprlock      # screen locking
    hyprpaper     # wallpaper
    hyprpicker    # color picker
    hypridle      # idle management
    hyprshot      # screenshot
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.variables = {
    XDG_PICTURES_DIR = "/home/cedric/.local/share/pictures"; # for hyprshot
  };
 
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
}
