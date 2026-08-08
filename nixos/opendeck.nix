{ pkgs, ... }:

let
  opendeckPackage = pkgs.callPackage ../packages/opendeck { };
  opendeck = opendeckPackage.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") +
      # bash
      ''
      substituteInPlace src-tauri/tauri.conf.json \
        --replace-fail \
          '"center": true,' \
          '"center": true, "decorations": false,'
    '';
  });
in
{
  environment.systemPackages = [ opendeck ];
  services.udev.packages = [ opendeck ];
}
