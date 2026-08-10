{ pkgs, lib, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/tty/refs/heads/main/themes/mocha.txt";
    sha256 = "sha256-Qw3V/OQZs+1NH4qW42nnUwArxZs7mnBADTDO4AzJPDo=";
  };
  fileContent = lib.strings.fileContents mochaTheme;
  themeValues = lib.strings.splitString " " fileContent;
in
{
  boot = {
    kernelParams = themeValues;
  };
}
