{ pkgs, ... }: {
  home.activation.setWallpaper = pkgs.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "${../wallpapers/chill-house.png}"'
  '';
}
