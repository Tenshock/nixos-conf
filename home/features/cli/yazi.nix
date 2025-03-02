{pkgs, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/yazi/5d50620344a0c7b83f6b5b907457b835844831c3/themes/mocha/catppuccin-mocha-teal.toml";
    sha256 = "sha256-aRnDYLzIL34KKT2U0nOaTunKLqUirQHIURW+d/grsYI=";
  };
in {
  # TODO: switch to flavors: https://yazi-rs.github.io/docs/flavors/overview/
  home.file.".config/yazi/theme.toml".source = mochaTheme;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };
}
