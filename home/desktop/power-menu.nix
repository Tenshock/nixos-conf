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
      if systemctl --user is-active --quiet stay-awake.service; then
        idle_toggle='󰅶  Allow idling'
      else
        idle_toggle='  Keep Awake'
      fi

      choice="$(
        printf '%s\n' \
          '  Logout' \
          '  Reboot' \
          '  Lock' \
          '  Shutdown' \
          "$idle_toggle" \
          '  Suspend' \
          '  Hibernate' \
          | env GSK_RENDERER=cairo walker --dmenu --width 250 --height 259 --placeholder Power
      )"

      case "$choice" in
        '  Logout') hyprctl dispatch 'hl.dsp.exit()' ;;
        '  Reboot') systemctl reboot ;;
        '  Lock') hyprlock ;;
        '  Shutdown') systemctl poweroff ;;
        '  Keep Awake') systemctl --user start stay-awake.service ;;
        '󰅶  Allow idling') systemctl --user stop stay-awake.service ;;
        '  Suspend') systemctl suspend-then-hibernate ;;
        '  Hibernate') systemctl hibernate ;;
      esac
    '';
  };
in
{
  home.packages = [ powerMenu ];
}
