{ pkgs, ... }:
{
  home.packages = [
    (pkgs.mongodb-compass.overrideAttrs (old: {
      # TODO: Remove this override once mongodb-compass no longer calls wrapGAppsHook manually.
      # The current package fails during build because wrapGAppsHook now expects fixup-phase output state.
      buildInputs = builtins.filter (pkg: pkg != pkgs.wrapGAppsHook3) (old.buildInputs or [ ]);
      buildCommand =
        builtins.replaceStrings [ "wrapGAppsHook $out/bin/mongodb-compass" ] [ ":" ]
          old.buildCommand;
    }))
  ];
}
