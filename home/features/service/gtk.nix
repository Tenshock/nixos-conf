{ pkgs, ... }:
{
  home.sessionVariables.GTK_THEME = "Adwaita:dark";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Adwaita:dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "kvantum";
    };
  };
}
