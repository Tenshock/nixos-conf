{ pkgs, ... }: {
  home = {
    packages = with pkgs; [ catppuccin-cursors.mochaPeach ];
    sessionVariables = {
      HYPRCURSOR_THEME = "MochaPeach";
      HYPRCURSOR_SIZE = 24;

      XCURSOR_THEME = "MochaPeach";
      XCURSOR_SIZE = 24;
    };

    pointerCursor = with pkgs; {
      enable = true;
      name = "MochaPeach";
      package = catppuccin-cursors.mochaPeach;
      size = 24;
      hyprcursor = {
        enable = true;
        size = 24;
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "'MochaPeach'";
    };
  };
}
