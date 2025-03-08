{ config, ... }:
let
  wallpaperSourceDir = ../../../wallpapers;
  wallpaperDestDir = "${config.xdg.configHome}/wallpapers";
  wallpaper = "chill-house.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${wallpaperDestDir}/${wallpaper}"
      ];
      wallpaper = [
        ",${wallpaperDestDir}/${wallpaper}"
      ];
    };
  };

  home.file.".wallpapers" = {
    source = wallpaperSourceDir;
    target = wallpaperDestDir;
  };
}
