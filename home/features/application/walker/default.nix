{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ pkgs.qalculate-gtk ];
  xdg = {
    configFile = {
      "elephant/elephant.toml".source = tomlFormat.generate "elephant.toml" {
        auto_detect_launch_prefix = false;
        launch_prefix = "${pkgs.uwsm}/bin/uwsm-app --";
      };

      "elephant/calc.toml".text = ''
        command = "${pkgs.qalculate-gtk}/bin/qalculate-gtk '%VALUE%'"
      '';

      "elephant/websearch.toml".text = ''
        [[entries]]
        default = true
        name = "DuckDuckGo"
        url = "https://duckduckgo.com/?q=%TERM%"
        icon = "duckduckgo"
      '';

      "elephant/1password.toml".text = ''
        vaults = ["personal"]
      '';
    };
  };

  services.elephant = {
    enable = true;
    settings.providers = {
      default = [
        "1password"
        "desktopapplications"
        "runner"
        "calc"
        "websearch"
      ];
      max_results = 50;
    };
  };

  services.walker = {
    enable = true;
    enableElephantIntegration = true;
    settings.app_launch_prefix = "uwsm app -- ";
    systemd.enable = true;
  };

  systemd.user.services.walker = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service.RestartSec = 10;
  };

  systemd.user.services.elephant = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service.RestartSec = 10;
  };
}
