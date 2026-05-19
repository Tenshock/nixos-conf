{
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchDocked = "suspend-then-hibernate";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "15min";
    HibernateOnACPower = true;
  };
}
