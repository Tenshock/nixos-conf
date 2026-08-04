{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs.firefox-addons.overlays.default pkgs pkgs) firefox-addons;
in
{
  imports = [
    ./look-and-feel.nix
    ./search-engines.nix
    ./shortcuts.nix
  ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    profiles.default = {
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
