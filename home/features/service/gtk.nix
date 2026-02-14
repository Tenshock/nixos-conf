{
  home.sessionVariables.GTK_THEME = "Adwaita:dark";

  dconf.settings = {
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
  };

  gtk = {
    enable = true;
    theme = { name = "Adwaita:dark"; };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = { name = "kvantum"; };
  };
}
