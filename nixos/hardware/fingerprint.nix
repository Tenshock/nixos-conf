{ pkgs, ... }:
{
  security.pam.services = {
    login.fprintAuth = false;
    greetd.fprintAuth = false;

    sudo.fprintAuth = true;
    hyprlock.fprintAuth = false;
    polkit-agent-helper-1.fprintAuth = true;

    hyprlock.text = ''
      auth sufficient ${pkgs.pam}/lib/security/pam_unix.so try_first_pass
      auth required ${pkgs.pam}/lib/security/pam_deny.so
    '';
  };

  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };
}
