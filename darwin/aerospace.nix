{
  system.defaults.spaces.spans-displays = true;

  services.aerospace = {
    enable = true;

    settings = {
      after-startup-command = [ ];

      start-at-login = false;

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;

      default-root-container-layout = "tiles";

      default-root-container-orientation = "auto";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
      # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
      # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
      automatically-unhide-macos-hidden-apps = false;

      key-mapping = {
        preset = "qwerty";
      };

      gaps = {
        inner = {
          horizontal = 5;
          vertical = 5;
        };
        outer = {
          left = 5;
          bottom = 5;
          top = 5;
          right = 5;
        };
      };

      mode.main.binding = {
        cmd-shift-h = "move-workspace-to-monitor left";
        cmd-shift-l = "move-workspace-to-monitor right";

        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-7 = "workspace 7";
        cmd-8 = "workspace 8";
        cmd-9 = "workspace 9";

        cmd-shift-1 = "move-node-to-workspace 1";
        cmd-shift-2 = "move-node-to-workspace 2";
        cmd-shift-3 = "move-node-to-workspace 3";
        cmd-shift-4 = "move-node-to-workspace 4";
        cmd-shift-5 = "move-node-to-workspace 5";
        cmd-shift-6 = "move-node-to-workspace 6";
        cmd-shift-7 = "move-node-to-workspace 7";
        cmd-shift-8 = "move-node-to-workspace 8";
        cmd-shift-9 = "move-node-to-workspace 9";
      };
    };
  };
}
