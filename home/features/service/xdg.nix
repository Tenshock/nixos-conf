{config, ... }: {
  xdg = {
    enable = true;
    userDirs.extraConfig = {
      #TODO: to move in hyprshot
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures";
    };
  };
}

