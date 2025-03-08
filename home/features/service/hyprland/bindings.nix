{
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$shiftMod" = "SUPER_SHIFT";

    bind = [
      "$mainMod, Q, exec, $terminal"
      "$mainMod, C, killactive,"
      ", F11, fullscreen,"
      "$mainMod, F, exec, $browser"
      "$mainMod, M, exec, ~/.local/bin/wofi_power_menu.sh"
      "$mainMod, L, exec, $hyprlock"
      "$shiftMod, L, exec, ~/.local/bin/lock-and-suspend.sh"
      "$mainMod, N, exec, $networkManager"
      "$mainMod, B, exec, $bluetoothManager"
      "$mainMod, H, exec, $audioManager"
      "$mainMod, P, exec, $cbonsai"
      "$mainMod, O, exec, $obsidian"
      "$mainMod, E, exec, $fileManager"
      "$mainMod, T, exec, $teams"
      "$mainMod, V, togglefloating,"
      "$mainMod, I, exec, hyprpicker -a"
      "$mainMod, SPACE, exec, ~/.local/bin/wofi_launcher.sh"
      "$shiftMod, D, togglesplit," # dwindle
      "$mainMod, D, swapsplit," # dwindle
      ", F10, exec, hyprshot -m output" # Screenshot a monitor
      ", PRINT, exec, hyprshot -m output" # Screenshot a monitor
      "$mainMod, S, exec, hyprshot -m output" # Screenshot a monitor
      "$shiftMod, PRINT, exec, hyprshot -m region" # Screenshot a region
      "$shiftMod, S, exec, hyprshot -m region" # Screenshot a region

      # Move focus with mainMod + arrow keys
      "$mainMod, left, movefocus, l"
      "$mainMod, right, movefocus, r"
      "$mainMod, up, movefocus, u"
      "$mainMod, down, movefocus, d"

      # Switch workspaces with mainMod + [0-9]
      "$mainMod, ampersand, workspace, 1"
      "$mainMod, eacute, workspace, 2"
      "$mainMod, quotedbl, workspace, 3"
      "$mainMod, apostrophe, workspace, 4"
      "$mainMod, parenleft, workspace, 5"
      "$mainMod, minus, workspace, 6"
      "$mainMod, egrave, workspace, 7"
      "$mainMod, underscore, workspace, 8"
      "$mainMod, ccedilla, workspace, 9"
      "$mainMod, agrave, workspace, 10"

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      "$shiftMod, ampersand, movetoworkspace, 1"
      "$shiftMod, eacute, movetoworkspace, 2"
      "$shiftMod, quotedbl, movetoworkspace, 3"
      "$shiftMod, apostrophe, movetoworkspace, 4"
      "$shiftMod, parenleft, movetoworkspace, 5"
      "$shiftMod, minus, movetoworkspace, 6"
      "$shiftMod, egrave, movetoworkspace, 7"
      "$shiftMod, underscore, movetoworkspace, 8"
      "$shiftMod, ccedilla, movetoworkspace, 9"
      "$shiftMod, agrave, movetoworkspace, 10"

      # Example special workspace (scratchpad)
      "$mainMod, A, togglespecialworkspace, magic"
      "$shiftMod, A, movetoworkspace, special:magic"
    ];

    bindm = [
      "$mainMod, Control_L, movewindow" # Move Window (mouse)
      "$mainMod, ALT_L, resizewindow" # Resize Window (mouse)
    ];

    bindl = [
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    bindel = [
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
      ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
    ];
  };
}
