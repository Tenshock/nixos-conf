{ pkgs, ... }:
let
  nvbroadcastNixpkgs = builtins.getFlake "path:/home/cedric/projects/own/nixpkgs";
in
{
  imports = [
    (nvbroadcastNixpkgs.outPath + "/nixos/modules/programs/nvbroadcast.nix")
  ];

  # The imported module is newer than the locked nixos input, so its manual
  # anchor is not present in the locked redirects.json yet.
  documentation.nixos.checkRedirects = false;

  programs.nvbroadcast = {
    enable = true;
    package = nvbroadcastNixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nvbroadcast;
  };
}

# {
#   programs.nvbroadcast.enable = true;
# }
