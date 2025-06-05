{ pkgs, ... }: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --theme 'text=darkgray;time=darkgray;container=darkgray;border=gray;title=darkgray;greet=darkgray;prompt=white;input=white;action=lightcyan;button=cyan' --greeting 'Authenticate to the sleeper build' --remember-session";
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYHangup = true;
    TTYVDisallocate = true;
  };
}
