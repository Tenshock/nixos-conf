let
  colors = {
    base = "rgba(1e1e2eff)";
    text = "rgba(cdd6f4ff)";
    yellow = "rgba(f9e2afff)";
    red = "rgba(f38ba8ff)";
  };
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      auth = {
        pam = {
          enabled = true;
          module = "hyprlock";
        };
        fingerprint.enabled = true;
      };

      general = {
        hide_cursor = true;
        animation = "fade, 1, 1.8, linear";
      };

      background = {
        path = "$XDG_CONFIG_HOME/wallpapers/chill-house.png";
        blur_passes = 1;
        blur_size = 5;
        color = colors.base;
      };

      label = [
        # TIME
        {
          text = "$TIME";
          color = colors.text;
          font_size = 90;
          font_family = "JetBrainsMono Nerd Font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }

        # DATE
        {
          text = ''cmd[update:43200000] date +"%A %d %B %Y"'';
          color = colors.text;
          font_size = 25;
          font_family = "JetBrainsMono Nerd Font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];

      # USER AVATAR
      image = {
        path = "$HOME/.face";
        size = 100;
        border_color = colors.yellow;
        position = "0, 75";
        halign = "center";
        valign = "center";
      };

      # INPUT FIELD
      input-field = {
        size = "300, 60";
        outline_thickness = 2;
        dots_size = "0.2";
        dots_spacing = "0.2";
        dots_center = true;
        outer_color = "rgba(00000000)";
        inner_color = "rgba(00000000)";
        font_color = colors.text;
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##cdd6f4"><i>󰌾 Logged in as </i><span foreground="##f9e2af">$USER</span></span>'';
        hide_input = true;
        check_color = colors.yellow;
        fail_color = colors.red;
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = colors.yellow;
        position = "0, -47";
        halign = "center";
        valign = "center";
      };
    };
  };
}
