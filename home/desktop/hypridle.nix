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
          # 10min30s: turn screen off and suspend, then hibernate after HibernateDelaySec.
          timeout = 630;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'; systemctl suspend-then-hibernate";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
        }
      ];
    };
  };
}
