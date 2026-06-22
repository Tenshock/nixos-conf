{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      opener = {
        open = [
          {
            run = ''xdg-open "$@"'';
            desc = "Open";
          }
        ];
      };

      open = {
        rules = [
          {
            mime = "video/*";
            use = "open";
          }
        ];
      };
    };
  };

  catppuccin.yazi.enable = true;
}
