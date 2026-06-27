{ pkgs, lib, ... }:
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

  environment.etc."greetd/sessions/hyprland-uwsm.desktop".source =
    "${pkgs.hyprland}/share/wayland-sessions/hyprland-uwsm.desktop";

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
  };
}
