{
  imports = [
    ../features/application/wofi.nix

    ../features/cli/hyprpicker.nix
    ../features/cli/hyprshot.nix
    ../features/cli/wl-clipboard.nix

    ../features/service/gtk.nix
    ../features/service/hypridle.nix
    ../features/service/hyprland/hyprland.nix# TODO: to finish, with scripts
    ../features/service/hyprlock.nix
    ../features/service/hyprpaper.nix
    ../features/service/mako.nix
    ../features/service/waybar/waybar.nix # TODO: to finish, with scripts
  ];
}
