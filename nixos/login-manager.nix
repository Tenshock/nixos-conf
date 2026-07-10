{ pkgs, lib, ... }:
let
  mkHyprlandSession =
    {
      name,
      profile,
    }:
    ''
      [Desktop Entry]
      Name=${name}
      Comment=Hyprland ${profile} GPU profile
      Exec=${pkgs.coreutils}/bin/env HYPRLAND_GPU_PROFILE=${profile} ${pkgs.uwsm}/bin/uwsm start -e -D Hyprland hyprland.desktop
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
    # Keep the old filename so tuigreet's remembered session remains valid.
    "greetd/sessions/hyprland-uwsm.desktop".text = mkHyprlandSession {
      name = "Hyprland Mobile";
      profile = "mobile";
    };
    "greetd/sessions/hyprland-egpu.desktop".text = mkHyprlandSession {
      name = "Hyprland eGPU Docked";
      profile = "egpu";
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
