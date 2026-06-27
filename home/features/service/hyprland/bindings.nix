{ lib, ... }:
let
  lua = lib.generators.mkLuaInline;

  exec = command: lua "hl.dsp.exec_cmd(${command})";

  bind = key: dispatcher: {
    _args = [
      key
      dispatcher
    ];
  };

  bindWithFlags = key: dispatcher: flags: {
    _args = [
      key
      dispatcher
      flags
    ];
  };

  main = key: lua "mainMod .. \" + ${key}\"";
  shift = key: lua "shiftMod .. \" + ${key}\"";

  directionBinds = [
    {
      key = "left";
      direction = "l";
    }
    {
      key = "right";
      direction = "r";
    }
    {
      key = "up";
      direction = "u";
    }
    {
      key = "down";
      direction = "d";
    }
  ];

  workspaceBinds = [
    {
      key = "ampersand";
      workspace = "1";
    }
    {
      key = "eacute";
      workspace = "2";
    }
    {
      key = "quotedbl";
      workspace = "3";
    }
    {
      key = "apostrophe";
      workspace = "4";
    }
    {
      key = "parenleft";
      workspace = "5";
    }
    {
      key = "minus";
      workspace = "6";
    }
    {
      key = "egrave";
      workspace = "7";
    }
    {
      key = "underscore";
      workspace = "8";
    }
    {
      key = "ccedilla";
      workspace = "9";
    }
    {
      key = "agrave";
      workspace = "10";
    }
  ];

  resizeBinds = [
    {
      key = "right";
      x = 10;
      y = 0;
    }
    {
      key = "left";
      x = -10;
      y = 0;
    }
    {
      key = "up";
      x = 0;
      y = -10;
    }
    {
      key = "down";
      x = 0;
      y = 10;
    }
  ];

  mkFocusBind =
    { key, direction }: bind (main key) (lua "hl.dsp.focus({ direction = \"${direction}\" })");

  mkWorkspaceBind =
    { key, workspace }: bind (main key) (lua "hl.dsp.focus({ workspace = \"${workspace}\" })");

  mkMoveToWorkspaceBind =
    { key, workspace }: bind (shift key) (lua "hl.dsp.window.move({ workspace = \"${workspace}\" })");

  mkResizeBind =
    {
      key,
      x,
      y,
    }:
    bindWithFlags key
      (lua "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })")
      {
        repeating = true;
      };
in
{
  wayland.windowManager.hyprland = {
    settings = {
      mainMod._var = "SUPER";
      shiftMod._var = "SUPER + SHIFT";

      bind = [
        (bind (main "Q") (exec "terminal"))
        (bind (main "C") (lua "hl.dsp.window.close()"))
        (bind "F11" (lua "hl.dsp.window.fullscreen()"))
        (bind (main "F") (exec "browser"))
        (bind (main "M") (exec "powerMenu"))
        (bind (main "L") (exec "hyprlock"))
        (bind (shift "L") (lua "hl.dsp.exec_cmd(\"systemctl suspend-then-hibernate\")"))
        (bind (main "N") (exec "networkManager"))
        (bind (main "B") (exec "bluetoothManager"))
        (bind (main "H") (exec "audioManager"))
        (bind (main "P") (exec "cbonsai"))
        (bind (main "O") (exec "obsidian"))
        (bind (main "E") (exec "fileManager"))
        (bind (main "T") (exec "teams"))
        (bind (main "V") (lua "hl.dsp.window.float()"))
        (bind (main "I") (lua "hl.dsp.exec_cmd(\"hyprpicker -a\")"))
        (bind (main "SPACE") (exec "walker"))
        (bind "CTRL + ALT + SPACE" (exec "smile"))
        (bind (shift "D") (lua "hl.dsp.layout(\"togglesplit\")")) # dwindle
        (bind (main "D") (lua "hl.dsp.layout(\"swapsplit\")")) # dwindle
        (bind "F10" (lua "hl.dsp.exec_cmd(\"hyprshot -m output\")")) # Screenshot a monitor
        (bind "Print" (lua "hl.dsp.exec_cmd(\"hyprshot -m output\")")) # Screenshot a monitor
        (bind (main "S") (lua "hl.dsp.exec_cmd(\"hyprshot -m output\")")) # Screenshot a monitor
        (bind (shift "Print") (lua "hl.dsp.exec_cmd(\"hyprshot -m region\")")) # Screenshot a region
        (bind (shift "S") (lua "hl.dsp.exec_cmd(\"hyprshot -m region\")")) # Screenshot a region
      ]
      ++ (map mkFocusBind directionBinds)
      ++ (map mkWorkspaceBind workspaceBinds)
      ++ (map mkMoveToWorkspaceBind workspaceBinds)
      ++ [
        # Example special workspace (scratchpad)
        (bind (main "A") (lua "hl.dsp.workspace.toggle_special(\"magic\")"))
        (bind (shift "A") (lua "hl.dsp.window.move({ workspace = \"special:magic\" })"))

        (bind (main "R") (lua "hl.dsp.submap(\"resize\")"))

        (bindWithFlags (main "Control_L") (lua "hl.dsp.window.drag()") { mouse = true; }) # Move Window (mouse)
        (bindWithFlags (main "ALT_L") (lua "hl.dsp.window.resize()") { mouse = true; }) # Resize Window (mouse)

        (bindWithFlags "XF86AudioNext" (lua "hl.dsp.exec_cmd(\"playerctl next\")") { locked = true; })
        (bindWithFlags "XF86AudioPause" (lua "hl.dsp.exec_cmd(\"playerctl play-pause\")") {
          locked = true;
        })
        (bindWithFlags "F9" (lua "hl.dsp.exec_cmd(\"playerctl play-pause\")") { locked = true; })
        (bindWithFlags "XF86AudioPlay" (lua "hl.dsp.exec_cmd(\"playerctl play-pause\")") { locked = true; })
        (bindWithFlags "XF86AudioPrev" (lua "hl.dsp.exec_cmd(\"playerctl previous\")") { locked = true; })

        (bindWithFlags "XF86AudioRaiseVolume"
          (lua "hl.dsp.exec_cmd(\"wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+\")")
          {
            locked = true;
            repeating = true;
          }
        )
        (bindWithFlags "XF86AudioLowerVolume"
          (lua "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
          {
            locked = true;
            repeating = true;
          }
        )
        (bindWithFlags "XF86AudioMute"
          (lua "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
          {
            locked = true;
            repeating = true;
          }
        )
        (bindWithFlags "XF86AudioMicMute"
          (lua "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
          {
            locked = true;
            repeating = true;
          }
        )
        (bindWithFlags "XF86MonBrightnessUp" (lua "hl.dsp.exec_cmd(\"brightnessctl s 10%+\")") {
          locked = true;
          repeating = true;
        })
        (bindWithFlags "XF86MonBrightnessDown" (lua "hl.dsp.exec_cmd(\"brightnessctl s 10%-\")") {
          locked = true;
          repeating = true;
        })
      ];
    };

    submaps.resize.settings.bind = (map mkResizeBind resizeBinds) ++ [
      (bind "escape" (lua "hl.dsp.submap(\"reset\")"))
      (bind "Return" (lua "hl.dsp.submap(\"reset\")"))
    ];
  };
}
