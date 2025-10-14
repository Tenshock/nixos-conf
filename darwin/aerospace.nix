{
  system.defaults.spaces.spans-displays = true;

  services.aerospace = {
    enable = false;

    settings = {
      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };

      on-focused-monitor-changed = [
        "move-mouse monitor-lazy-center"
      ];
    };
  };
}
