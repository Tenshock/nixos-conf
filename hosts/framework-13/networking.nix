{ hostName, user }: {
  networking = {
    inherit hostName;
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    firewall.enable = true;
  };

  users.users.${user} = {
    extraGroups = [ "networkmanager" ];
  };
}
