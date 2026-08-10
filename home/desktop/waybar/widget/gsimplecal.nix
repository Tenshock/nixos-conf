{ pkgs, ... }:
let
  gsimplecal = pkgs.gsimplecal.overrideAttrs (old: {
    postPatch = (old.postPatch or "") +
      # bash
      ''
      substituteInPlace src/MainWindow.cpp \
        --replace-fail '    gtk_window_set_title(GTK_WINDOW(widget), "gsimplecal");' '    gtk_widget_set_name(widget, "gsimplecal-waybar");
          gtk_window_set_title(GTK_WINDOW(widget), "gsimplecal");'
    '';
  });
in
{
  home.packages = [ gsimplecal ];

  home.file.".config/gsimplecal/config".text =
    # ini
    ''
    show_calendar = 1
    show_timezones = 0
    mark_today = 1
    show_week_numbers = 0
    close_on_unfocus = 0
    close_on_mouseleave = 0
    mainwindow_decorated = 0
    mainwindow_keep_above = 1
    mainwindow_sticky = 1
    mainwindow_skip_taskbar = 1
    mainwindow_resizable = 0
    mainwindow_position = none
    mainwindow_xoffset = 0
    mainwindow_yoffset = 0
  '';

  gtk.gtk3.extraCss =
    # css
    ''
    window#gsimplecal-waybar,
    window#gsimplecal-waybar > box {
      background-color: rgba(15, 17, 26, 0.75);
      color: #cdd6f4;
    }

    window#gsimplecal-waybar {
      border-radius: 0 0 16px 16px;
    }

    window#gsimplecal-waybar calendar {
      background-color: transparent;
      color: #cdd6f4;
    }

    window#gsimplecal-waybar calendar:selected {
      background-color: #e5c76b;
      color: #1e1e2e;
    }
  '';
}
