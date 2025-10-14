{ pkgs, ... }: {
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 14;
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
    };

    settings = {
      macos_option_as_alt = "left";
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      cursor_trail = 50;
      cursor_trail_start_threshold = 2;
    };

    themeFile = "Catppuccin-Mocha";
    extraConfig = ''
      background #0f111a
    '';
  };
}
