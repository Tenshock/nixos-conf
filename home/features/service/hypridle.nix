{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        before_sleep_cmd = "hyprlock";
      };

      listener = [
        {
          # 9min30 turn monitor backlight off
          timeout = 530;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          # 9min30: turn keyboard backlight off
          timeout = 530;
          on-timeout = "brightnessctl -sd dell::kbd_backlight set 0";
          on-resume = "brightnessctl -rd dell::kbd_backlight";
        }
        {
          # 10min: lock session
          timeout = 600;
          on-timeout = "hyprlock";
        }
        {
          # 10min30s: turn screen off
          timeout = 630;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # 30 minutes: suspend then hibernate. See "HibernateDelaySec" in logind conf in configuration.nix.
          timeout = 1800;
          on-timeout = "systemctl suspend-then-hibernate";
        }
      ];
    };
  };
}
