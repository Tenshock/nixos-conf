{ pkgs, ... }:
let
  hosts = import ../hosts.nix;
in
{
  networking.hostName = hosts.laptop-srp.hostname;
  networking.networkmanager.enable = true;

  users.users.${hosts.laptop-srp.user} = {
    extraGroups = [ "networkmanager" ];
  };
}
