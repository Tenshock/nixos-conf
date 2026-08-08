{ pkgs, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "peach" ];
  };
  catppuccinKvantum = pkgs.catppuccin-kvantum.override {
    variant = "mocha";
    accent = "peach";
  };
  themeName = "catppuccin-mocha-peach-standard";
  kvantumThemeName = "catppuccin-mocha-peach";
in
{
  home.sessionVariables.GTK_THEME = themeName;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "menu:";
    };
  };

  gtk = {
    enable = true;
    gtk3.extraConfig.gtk-decoration-layout = "menu:";
    gtk4.extraConfig.gtk-decoration-layout = "menu:";
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = themeName;
      package = catppuccinGtk;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style = {
      name = "kvantum";
    };
  };

  xdg.configFile = {
    "gtk-4.0/gtk.css".source = "${catppuccinGtk}/share/themes/${themeName}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${catppuccinGtk}/share/themes/${themeName}/gtk-4.0/gtk-dark.css";
    "Kvantum/${kvantumThemeName}".source = "${catppuccinKvantum}/share/Kvantum/${kvantumThemeName}";
    "Kvantum/kvantum.kvconfig".text =
      # ini
      ''
      [General]
      theme=${kvantumThemeName}
    '';
  };
}
