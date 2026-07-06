{ pkgs, ... }:
{
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    bluetui # bluetooth controller TUI
    ncpamixer # sound mixer TUI
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # audio controllers
  services = {
    playerctld.enable = true;
    pipewire = {
      enable = true;
      audio.enable = true;
      wireplumber.enable = true;
      # extraConfig.pipewire-pulse."92-echo-cancel" = {
      #   "pulse.cmd" = [
      #     {
      #       cmd = "load-module";
      #       args = "module-echo-cancel source_name=echo_cancel_source source_master=alsa_input.usb-Logitech_Yeti_GX_2612SGN00W28-00.mono-fallback sink_name=echo_cancel_sink sink_master=alsa_output.pci-0000_c1_00.6.analog-stereo aec_method=webrtc";
      #       flags = [ "nofail" ];
      #     }
      #   ];
      # };
    };
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
  };

  # systemd.user.services.pipewire-echo-cancel-defaults = {
  #   description = "Set PipeWire Pulse echo-cancel defaults";
  #   after = [ "pipewire-pulse.service" ];
  #   wantedBy = [ "pipewire-pulse.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "pipewire-echo-cancel-defaults" ''
  #       set -eu
  #
  #       for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
  #         sources="$(${pkgs.pulseaudio}/bin/pactl list short sources 2>/dev/null || true)"
  #         sinks="$(${pkgs.pulseaudio}/bin/pactl list short sinks 2>/dev/null || true)"
  #
  #         if printf '%s\n' "$sources" | ${pkgs.gnugrep}/bin/grep -q 'echo_cancel_source' \
  #           && printf '%s\n' "$sources" | ${pkgs.gnugrep}/bin/grep -q 'easyeffects_source' \
  #           && printf '%s\n' "$sinks" | ${pkgs.gnugrep}/bin/grep -q 'echo_cancel_sink' \
  #           && ${pkgs.pulseaudio}/bin/pactl set-default-source easyeffects_source 2>/dev/null \
  #           && ${pkgs.pulseaudio}/bin/pactl set-default-sink echo_cancel_sink 2>/dev/null; then
  #           exit 0
  #         fi
  #
  #         ${pkgs.coreutils}/bin/sleep 0.5
  #       done
  #
  #       echo "echo_cancel_source, easyeffects_source, or echo_cancel_sink not found" >&2
  #       exit 1
  #     '';
  #   };
  # };
}
