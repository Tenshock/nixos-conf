{ config, pkgs, ... }:
let
  nvbroadcastNixpkgs = builtins.getFlake "path:/home/cedric/projects/own/nixpkgs";
in
{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (final: prev: {
        nvbroadcast = nvbroadcastNixpkgs.legacyPackages.${prev.stdenv.hostPlatform.system}.nvbroadcast;
      })
    ];
  };

  boot = {
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=10 card_label="NVbroadcast" exclusive_caps=1 max_buffers=4
    '';
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    kernelModules = [ "v4l2loopback" ];
  };

  environment.systemPackages = [
    pkgs.nvbroadcast
  ];
}

# { config, pkgs, ... }:
#
# {
#   boot = {
#     extraModprobeConfig = ''
#       options v4l2loopback devices=1 video_nr=10 card_label="NVbroadcast" exclusive_caps=1 max_buffers=4
#     '';
#     extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
#     kernelModules = [ "v4l2loopback" ];
#   };
#
#   environment.systemPackages = [
#     pkgs.nvbroadcast
#   ];
# }
