let
  hosts = import ../hosts.nix;
in {
  networking = {
    hostName = hosts.framework-13.hostname;
    networkmanager.enable = true;
  };

  users.users.${hosts.framework-13.user} = {
    extraGroups = [ "networkmanager" ];
  };
}
