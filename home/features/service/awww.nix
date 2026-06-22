{ config, pkgs, ... }:
let
  wallpaperSourceDir = ../../../wallpapers;
  wallpaperDestDir = "${config.xdg.configHome}/wallpapers";
  awwwSwitch = pkgs.writeShellApplication {
    name = "awww-switch";
    runtimeInputs = [
      pkgs.awww
      pkgs.coreutils
      pkgs.findutils
    ];
    text = ''
      wallpaper="$(
        find -L "${wallpaperDestDir}" -maxdepth 1 -type f -name '*.gif' \
          | shuf -n 1
      )"

      if [ -z "$wallpaper" ]; then
        echo "No gif wallpaper found in ${wallpaperDestDir}" >&2
        exit 1
      fi

      awww img --resize crop --transition-type random "$wallpaper"
    '';
  };
in
{
  home.packages = [ awwwSwitch ];

  xdg.desktopEntries.awww-switch = {
    name = "wallpaper switch";
    exec = "awww-switch";
    icon = "preferences-desktop-wallpaper";
    terminal = false;
    categories = [ "Utility" ];
  };

  services.awww = {
    enable = true;
    extraArgs = [ "--no-cache" ];
  };

  systemd.user.services.awww-wallpaper = {
    Unit = {
      Description = "Set awww wallpaper";
      After = [ "awww.service" ];
      Requires = [ "awww.service" ];
      PartOf = [ "awww.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "set-awww-wallpaper" ''
        ${pkgs.coreutils}/bin/sleep 1
        ${awwwSwitch}/bin/awww-switch
      '';
    };

    Install.WantedBy = [ "awww.service" ];
  };

  home.file."wallpapers" = {
    source = wallpaperSourceDir;
    target = wallpaperDestDir;
  };
}
