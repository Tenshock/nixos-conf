{ hostName, user }: {
  networking = {
    inherit hostName;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall.enable = true;
  };

  users.users.${user} = {
    extraGroups = [ "networkmanager" ];
  };
}
