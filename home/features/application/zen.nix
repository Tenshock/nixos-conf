{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs.firefox-addons.overlays.default pkgs pkgs) firefox-addons;
in
{
  home = {
    file = {
      ".zen/e3dki2qs.Default Profile/chrome/userChrome.css".source =
        ./zen/catppuccin-mocha-peach/userChrome.css;
      ".zen/e3dki2qs.Default Profile/chrome/userContent.css".source =
        ./zen/catppuccin-mocha-peach/userContent.css;
      ".zen/e3dki2qs.Default Profile/chrome/zen-logo-mocha.svg".source =
        ./zen/catppuccin-mocha-peach/zen-logo-mocha.svg;
    };
  };

  xdg.configFile."zen/default/chrome/zen-logo-mocha.svg".source =
    ./zen/catppuccin-mocha-peach/zen-logo-mocha.svg;

  programs.zen-browser = {
    enable = true;
    extraPrefs = ''
      pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    '';
    setAsDefaultBrowser = true;

    profiles.default = {
      extensions.packages = with firefox-addons; [
        ublock-origin
        onepassword-password-manager
      ];

      settings."toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      userChrome = ./zen/catppuccin-mocha-peach/userChrome.css;
      userContent = ./zen/catppuccin-mocha-peach/userContent.css;
    };
  };
}
