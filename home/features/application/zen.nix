{
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs.firefox-addons.overlays.default pkgs pkgs) firefox-addons;
in
{
  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    profiles.default.extensions.packages = with firefox-addons; [
      ublock-origin
      onepassword-password-manager
    ];
  };
}
