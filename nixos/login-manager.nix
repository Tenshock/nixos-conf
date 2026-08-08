{ pkgs, lib, ... }:
let
  mkHyprlandSession =
    {
      name,
      gpuProfile ? "igpu",
      appProfile ? "default",
    }:
    # ini
    ''
      [Desktop Entry]
      Name=${name}
      Comment=Hyprland ${appProfile} ${gpuProfile}
      Exec=${pkgs.coreutils}/bin/env HYPRLAND_GPU_PROFILE=${gpuProfile} HYPRLAND_APP_PROFILE=${appProfile} ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop
      TryExec=${pkgs.uwsm}/bin/uwsm
      DesktopNames=Hyprland
      Type=Application
    '';
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = lib.concatStringsSep " " [
          "${pkgs.tuigreet}/bin/tuigreet"
          "--time"
          "--sessions /etc/greetd/sessions"
          "--theme 'text=darkgray;time=darkgray;container=darkgray;border=gray;title=darkgray;greet=darkgray;prompt=white;input=white;action=lightcyan;button=cyan'"
          "--greeting 'Authenticate to the sleeper build'"
          "--remember"
          "--remember-session"
        ];
        user = "greeter";
      };
    };
  };

  environment.etc = {
    "greetd/sessions/hyprland.desktop".text = mkHyprlandSession {
      name = "Hyprland";
    };
    "greetd/sessions/hyprland-work.desktop".text = mkHyprlandSession {
      name = "Hyprland - Work";
      appProfile = "work";
    };
    "greetd/sessions/hyprland-egpu.desktop".text = mkHyprlandSession {
      name = "Hyprland - eGPU";
      gpuProfile = "egpu";
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
  };
}
