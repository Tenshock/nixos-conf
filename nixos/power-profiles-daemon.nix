{ pkgs, ... }:
{
  services.power-profiles-daemon.enable = true;

  systemd.services.auto-power-profile = {
    description = "Switch power profile based on AC state";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    requires = [ "power-profiles-daemon.service" ];
    path = [
      pkgs.power-profiles-daemon
      pkgs.systemd
    ];
    script = ''
      profile_for_power_source() {
        local supply type online

        for supply in /sys/class/power_supply/*; do
          if [[ ! -r "$supply/type" || ! -r "$supply/online" ]]; then
            continue
          fi

          read -r type < "$supply/type"
          read -r online < "$supply/online"
          if [[ "$type" == "Mains" && "$online" == "1" ]]; then
            echo performance
            return
          fi
        done

        echo balanced
      }

      apply_profile() {
        local current target

        target="$(profile_for_power_source)"
        current="$(powerprofilesctl get)"
        if [[ "$current" != "$target" ]]; then
          echo "Switching power profile from $current to $target"
          powerprofilesctl set "$target"
        fi
      }

      apply_profile
      while IFS= read -r _; do
        apply_profile
      done < <(udevadm monitor --udev --subsystem-match=power_supply)
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = 2;
    };
  };
}
