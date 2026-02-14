user: { pkgs, ... }: {
  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ user ];
    };
  };

  environment.systemPackages = [ pkgs.polkit_gnome ];

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "Polkit GNOME Authentication Agent";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart =
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
        google-chrome
      '';
      mode = "0755";
    };
  };
}
