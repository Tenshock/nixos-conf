{ pkgs, config, ... }: {
  home = {
    packages = with pkgs; [
      hyprshot
    ];

    sessionVariables = {
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures";
    };
  };
}
