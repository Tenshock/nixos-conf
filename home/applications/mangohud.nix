{
  programs.mangohud = {
    enable = true;
    settings = {
      fps = true;
      frametime = true;
      gpu_stats = true;
      gpu_name = true;
      vram = true;
      engine_version = true;
      engine_short_names = true;
      wine = true;
      fps_limit = [
        120
        100
        0
      ];
      toggle_fps_limit = "Shift_R+F1";
      position = "top-right";
    };
  };
}
