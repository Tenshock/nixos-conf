{
  programs.hyprlock = {
    enable = true;
    sourceFirst = true;

    settings = {
      source = "$XDG_CONFIG_HOME/hypr/mocha.conf";

      "$accent" = "$yellow";
      "$font" = "JetBrainsMono Nerd Font";

      general = {
        hide_cursor = true;
        animation = "fade, 1, 1.8, linear";
      };

      background = {
        path = "$XDG_CONFIG_HOME/wallpapers/chill-house.png";
        blur_passes = 1;
        blur_size = 5;
        color = "$base";
      };

      label = [
        # TIME
        {
          text = "$TIME";
          color = "$text";
          font_size = 90;
          font_family = "$font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }

        # DATE
        {
          text = ''cmd[update:43200000] date +"%A %d %B %Y"'';
          color = "$text";
          font_size = 25;
          font_family = "$font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];

      # USER AVATAR
      image = {
        path = "$HOME/.face";
        size = 100;
        border_color = "$accent";
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
        font_color = "$text";
        fade_on_empty = false;
        placeholder_text = ''<span foreground="##$textAlpha"><i>󰌾 Logged in as </i><span foreground="##$yellowAlpha">$USER</span></span>'';
        hide_input = true;
        check_color = "$accent";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        capslock_color = "$yellow";
        position = "0, -47";
        halign = "center";
        valign = "center";
      };
    };
  };
}
