{ pkgs, ... }:
let
  catppuccinGtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "peach" ];
  };
in
{
  home.sessionVariables.GTK_THEME = "catppuccin-mocha-peach-standard";

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
      name = "catppuccin-mocha-peach-standard";
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
}
