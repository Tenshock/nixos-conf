{ pkgs, config, ... }: {
  home = {
    packages = with pkgs; [
      hyprshot
    ];

    # TODO: to fix
    sessionVariables = {
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/Pictures";
    };
  };
}
