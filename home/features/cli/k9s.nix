{pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/k9s/4432383da214face855a873d61d2aa914084ffa2/dist/catppuccin-mocha-transparent.yaml";
    sha256 = "sha256-ZPf7GVnbVOOsoB/wVevxFDwPayk2xKfMul8HXQVGUeE=";
  };
in {
  home.file."${config.xdg.configHome}/k9s/skins/mocha.yaml".source = mochaTheme;

  programs.k9s = {
    enable = true;
    settings = {
      k9s.ui.skin = "mocha";
    };
  };
}
