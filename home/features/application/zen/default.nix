{
  config,
  dependencies,
  pkgs,
  ...
}:
let
  firefox-addons = dependencies.mkFirefoxAddons pkgs;
in
{
  imports = [
    dependencies.homeModules.zenTwilight

    ./look-and-feel.nix
    ./search-engines.nix
    ./shortcuts.nix
  ];

  home.file."${config.home.homeDirectory}/.zen/profiles.ini".force = true;

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    configPath = "${config.home.homeDirectory}/.zen";

    profiles.default = {
      name = "Default Profile";
      path = "default";

      extensions.packages = with firefox-addons; [
        ublock-origin
        onepassword-password-manager
      ];

      settings = {
        "extensions.autoDisableScopes" = 0;
        "zen.welcome-screen.seen" = true;
      };
    };
  };
}
