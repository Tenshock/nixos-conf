{ config, pkgs, ... }:
let
  wallpaperSourceDir = ../../wallpapers;
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
  awwwRestoreAfterMonitor = pkgs.writeShellScript "awww-restore-after-monitor" ''
    for delay in 1 2 4; do
      ${pkgs.coreutils}/bin/sleep "$delay"

      if ${pkgs.awww}/bin/awww restore -a; then
        if ! ${pkgs.awww}/bin/awww query | ${pkgs.gnugrep}/bin/grep -q "currently displaying: color:"; then
          echo "awww restore succeeded after monitor change"
          exit 0
        fi
      fi

      echo "awww restore failed after waiting ''${delay}s; retrying" >&2
    done

    echo "awww restore failed after monitor change" >&2
    exit 1
  '';
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
        if ${pkgs.awww}/bin/awww restore -a; then
          if ! ${pkgs.awww}/bin/awww query | ${pkgs.gnugrep}/bin/grep -q "currently displaying: color:"; then
            exit 0
          fi
        fi

        ${awwwSwitch}/bin/awww-switch
      '';
    };

    Install.WantedBy = [ "awww.service" ];
  };

  systemd.user.services.awww-restore-after-monitor = {
    Unit = {
      Description = "Restore awww wallpaper after monitor layout changes";
      After = [
        "awww.service"
        "awww-wallpaper.service"
      ];
      Requires = [ "awww.service" ];
      PartOf = [ "awww.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = awwwRestoreAfterMonitor;
    };
  };

  wayland.windowManager.hyprland.extraConfig =
    # lua
    ''
      local restore_awww_after_monitor_change = function()
        hl.exec_cmd("${pkgs.systemd}/bin/systemctl --user start awww-restore-after-monitor.service")
      end

      hl.on("monitor.added", restore_awww_after_monitor_change)
      hl.on("monitor.layout_changed", restore_awww_after_monitor_change)
      hl.on("monitor.removed", restore_awww_after_monitor_change)
    '';

  home.file."wallpapers" = {
    source = wallpaperSourceDir;
    target = wallpaperDestDir;
  };
}
