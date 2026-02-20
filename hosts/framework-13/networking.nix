{ hostName, user }: {
  networking = {
    inherit hostName;
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1 unyka.local
      127.0.0.1 unyka-bo.local
    '';
    firewall.enable = false;
  };

  users.users.${user} = {
    extraGroups = [ "networkmanager" ];
  };
}
