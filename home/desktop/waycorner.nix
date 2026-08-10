{ pkgs, ... }:
{
  home.packages = with pkgs; [ waycorner ];

  xdg.configFile."waycorner/config.toml".source = (pkgs.formats.toml { }).generate "waycorner.toml" {
    lock = {
      enter_command = [ "hyprlock" ];
      locations = [ "bottom_left" ];
      size = 20;
      timeout_ms = 500;
    };
  };

  systemd.user.services.waycorner = {
    Unit = {
      Description = "Hot corners for Wayland";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.waycorner}/bin/waycorner";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
