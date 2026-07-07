{ pkgs, ... }:

let
  xdg-desktop-portal-hyprland-with-cursor =
    pkgs.xdg-desktop-portal-hyprland.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        substituteInPlace src/portals/Screencopy.hpp \
          --replace-fail 'cursorMode  = HIDDEN;' 'cursorMode  = EMBEDDED;'
      '';
    });
in
{
  # Needed to add a desktop entry at NixOS level.
  programs.hyprland = {
    enable = true;
    portalPackage = xdg-desktop-portal-hyprland-with-cursor;
    withUWSM = true;
  };
}
