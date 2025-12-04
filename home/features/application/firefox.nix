{ pkgs, ... }: {
  home.packages = with pkgs;
    [ ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [ google-chrome ];

  programs = { firefox.enable = true; };
}
