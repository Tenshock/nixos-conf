{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.tchap-desktop.packages.${pkgs.stdenv.hostPlatform.system}.tchap-desktop
  ];
}
