{
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
      '';
    };
  };

  programs = {
    _1password.enable = true;
    _1password-gui.enable = true;
  };
}
