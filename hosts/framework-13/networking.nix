# TODO: currying hostname and user
let hosts = import ../hosts.nix;
in {
  networking = {
    hostName = hosts.framework-13.hostname;
    networkmanager.enable = true;
    extraHosts = ''
      127.0.0.1 unyka.local
      127.0.0.1 unyka-bo.local
    '';
    firewall.enable = false;
  };

  users.users.${hosts.framework-13.user} = {
    extraGroups = [ "networkmanager" ];
  };
}
