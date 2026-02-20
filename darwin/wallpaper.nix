let
  img = toString ../wallpapers/chill-house.png;
in {
  launchd.user.agents.set-wallpaper = {
    serviceConfig = {
      ProgramArguments = [
        "/usr/bin/osascript" "-e"
        ''tell application "System Events" to tell every desktop to set picture to POSIX file "${img}"''
      ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/tmp/set-wallpaper.out";
      StandardErrorPath = "/tmp/set-wallpaper.err";
    };
  };
}
