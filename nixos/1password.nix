user: {
  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ user ];
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
