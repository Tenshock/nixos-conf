{pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/k9s/4432383da214face855a873d61d2aa914084ffa2/dist/catppuccin-mocha.yaml";
    sha256 = "sha256-rwkJQa7wiZ6Eb3wy4IilNov1iHI7dDTUTFq79Tw52pc";
  };
in {
  home.file."${config.xdg.configHome}/k9s/skins/mocha.yaml".source = mochaTheme;

  programs.k9s = {
    enable = true;
    settings = {
      ui.skin = "mocha";
    };
  };
}
