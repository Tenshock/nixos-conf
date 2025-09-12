{ pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/catppuccin/yazi/5d50620344a0c7b83f6b5b907457b835844831c3/themes/mocha/catppuccin-mocha-yellow.toml";
    sha256 = "sha256-sharychsswuyUjTUrNh8SkneMftIOX6dFE6T6Ap6lgA=";
  };
in {
  home.file."${config.xdg.configHome}/yazi/flavors/catppuccin-mocha.yazi/flavor.toml".source =
    mochaTheme;

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    theme = {
      flavor = {
        dark = "catppuccin-mocha";
        light = "catppuccin-mocha";
      };
    };
    settings = {
      opener = {
        open = [{
          run = ''xdg-open "$@"'';
          desc = "Open";
        }];
      };

      open = {
        rules = [{
          mime = "video/*";
          use = "open";
        }];
      };
    };
  };
}
