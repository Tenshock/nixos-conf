{ pkgs, ... }: {
  security = {
    polkit.enable = true;

    pam.services = {
      login.fprintAuth = true;
      sudo.fprintAuth = true;
      greetd.fprintAuth = true;
    };
  };

  services = {
    fprintd = {
      enable = true;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
}
