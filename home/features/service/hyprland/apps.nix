{ pkgs, ... }:
let
  onePasswordSignin = pkgs.writeShellApplication {
    name = "onepassword-signin";
    runtimeInputs = with pkgs; [
      _1password-cli
      _1password-gui
    ];
    text = ''
      1password --silent &

      for _ in {1..40}; do
        [ -S "''${XDG_RUNTIME_DIR:?}/1Password-BrowserSupport.sock" ] && break
        sleep 0.25
      done

      [ -S "$XDG_RUNTIME_DIR/1Password-BrowserSupport.sock" ] || exit 1
      exec op signin
    '';
  };
in
{
  wayland.windowManager.hyprland.settings = {
    audioManager._var = "uwsm app -- $(kitty -e ncpamixer)";
    bluetoothManager._var = "uwsm app -- kitty -e bluetui";
    browser._var = "uwsm app -- zen-twilight";
    fileManager._var = "uwsm app -- thunar";
    hyprlock._var = "uwsm app -- hyprlock";
    mattermost._var = "uwsm app -- mattermost-desktop";
    networkManager._var = "uwsm app -- $(kitty -e nmtui)";
    notificationCenter._var = "uwsm app -- swaync-client -t -sw";
    obsidian._var = "uwsm app -- obsidian";
    loginToOnePassword._var = "uwsm app -- ${onePasswordSignin}/bin/onepassword-signin";
    powerMenu._var = "uwsm app -- power-menu";
    smile._var = "uwsm app -- smile";
    tchap._var = "uwsm app -- tchap-desktop";
    teams._var = "uwsm app -- teams-for-linux";
    terminal._var = "uwsm app -- kitty";
    vesktop._var = "uwsm app -- vesktop";
    walker._var = "uwsm app -- walker";
  };
}
