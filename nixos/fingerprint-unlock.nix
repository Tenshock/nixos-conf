{ pkgs, ... }: {
  programs.seahorse.enable = true;

  security = {
    polkit.enable = true;
    soteria.enable = true;

    pam.services = {
      login.fprintAuth = true;
      login.enableGnomeKeyring = true;

      sudo.fprintAuth = true;
      # echo le canard laqué | gnome-keyring-daemon --unlock
      hyprlock.fprintAuth = true;
      # # ??
      # hyprlock.enableGnomeKeyring = true;
      # hyprlock.text = ''
      #   # Environment first (like default login)
      #   auth      required    pam_env.so
      #
      #   # Prefer password: immediate success if correct
      #   auth      sufficient  pam_unix.so try_first_pass nullok
      #
      #   # Or fingerprint (non-blocking if you don't touch it)
      #   # Short timeout keeps it snappy if the sensor is idle
      #   auth      sufficient  pam_fprintd.so max_tries=3 timeout=2
      #
      #   # If neither worked, fail
      #   auth      required    pam_deny.so
      #
      #   account   required    pam_unix.so
      #   password  required    pam_unix.so
      #
      #   session   required    pam_limits.so
      #   session   optional    pam_keyinit.so revoke
      #   session   optional    pam_gnome_keyring.so auto_start
      #   session   required    pam_unix.so
      # '';
      greetd.fprintAuth = true;
      greetd.enableGnomeKeyring = true;

      polkit-agent-helper-1.fprintAuth = true;
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;

    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
}
