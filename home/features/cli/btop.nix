{pkgs, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/btop/f437574b600f1c6d932627050b15ff5153b58fa3/themes/catppuccin_mocha.theme";
    sha256 = "sha256-THRpq5vaKCwf9gaso3ycC4TNDLZtBB5Ofh/tOXkfRkQ=";
  };
in {
  home.file.".config/btop/themes/mocha.theme".source = mochaTheme;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "mocha";
    };
  };
}
