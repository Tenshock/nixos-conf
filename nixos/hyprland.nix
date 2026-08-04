{ pkgs, ... }:

let
  xdg-desktop-portal-hyprland-with-cursor =
    pkgs.xdg-desktop-portal-hyprland.overrideAttrs
      (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace src/portals/Screencopy.hpp \
            --replace-fail 'cursorMode  = HIDDEN;' 'cursorMode  = EMBEDDED;'
        '';
      });
in
{
  # TODO: Temporary workaround for https://github.com/NixOS/nixpkgs/pull/549253.
  nixpkgs.overlays = [
    (_final: prev: {
      hyprland = prev.hyprland.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace CMakeLists.txt start/CMakeLists.txt hyprpm/CMakeLists.txt \
            --replace-fail "glaze 7...<8" "glaze"
        '';
      });
    })
  ];

  # Needed to add a desktop entry at NixOS level.
  programs.hyprland = {
    enable = true;
    portalPackage = xdg-desktop-portal-hyprland-with-cursor;
    withUWSM = true;
  };
}
