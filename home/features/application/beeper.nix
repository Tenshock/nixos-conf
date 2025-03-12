
{ pkgs, ... }:
let
  beeper = pkgs.fetchurl {
    url = "https://api.beeper.com/desktop/download/linux/x64/stable/com.automattic.beeper.desktop";
    sha256 = "sha256-60PBTfbgYf73bCY2Qxqy8I2vMCziHf5Nuw78cpbVi/8=";
  };
in {
  home.file.".local/bin/beeper.AppImage" = {
    source = beeper;
    executable = true;
  };
}
