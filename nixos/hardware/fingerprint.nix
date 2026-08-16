{ pkgs, ... }:
{
  security.pam.services = {
    login.fprintAuth = false;
    greetd.fprintAuth = false;

    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    polkit-agent-helper-1.fprintAuth = true;

    hyprlock.text = ''
      auth sufficient ${pkgs.pam}/lib/security/pam_unix.so try_first_pass
      auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
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
