{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "wofi-launcher" (builtins.readFile ./wofi-launcher.sh))
    (writeShellScriptBin "wofi-power-menu"
      (builtins.readFile ./wofi-power-menu.sh))
  ];

  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      width = "30%";
      height = "40%";
      prompt = "What is your desire…";
      normal_window = true;
      location = "center";
      gtk-dark = true;
      allow_images = true;
      image_size = 32;
      hide_scroll = true;
      show_all = true;
      insensitive = true;
      allow_markup = true;
      no_actions = true;
      orientation = "vertical";
      halign = "fill";
      content_halign = "fill";
    };
    style = builtins.readFile ./style.css;
  };
}
