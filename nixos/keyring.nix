{
  programs.seahorse.enable = true;

  security.pam.services = {
    login.enableGnomeKeyring = true;
    greetd.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = true;
}
