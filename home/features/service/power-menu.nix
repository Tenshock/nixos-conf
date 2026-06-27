{ pkgs, ... }:
let
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.hyprlock
      pkgs.systemd
      pkgs.walker
    ];
    text = ''
      choice="$(
        printf '%s\n' \
          '  Lock' \
          '  Logout' \
          '  Reboot' \
          '  Shutdown' \
          '  Suspend' \
          '  Hibernate' \
          | walker --dmenu --width 250 --height 223 --placeholder Power
      )"

      case "$choice" in
        '  Lock') hyprlock ;;
        '  Logout') hyprctl dispatch 'hl.dsp.exit()' ;;
        '  Reboot') systemctl reboot ;;
        '  Shutdown') systemctl poweroff ;;
        '  Suspend') systemctl suspend-then-hibernate ;;
        '  Hibernate') systemctl hibernate ;;
      esac
    '';
  };
in
{
  home.packages = [ powerMenu ];
}
