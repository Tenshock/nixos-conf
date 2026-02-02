{ config, ... }:
let
  wallpaperSourceDir = ../../../wallpapers;
  wallpaperDestDir = "${config.xdg.configHome}/wallpapers";
  wallpaper = "chill-house.png";
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wallpaperDestDir}/${wallpaper}" ];
      wallpaper = [{
        monitor = "";
        path = "${wallpaperDestDir}/${wallpaper}";
        fit_mode = "cover";
      }];
    };
  };

  home.file."wallpapers" = {
    source = wallpaperSourceDir;
    target = wallpaperDestDir;
  };
}
