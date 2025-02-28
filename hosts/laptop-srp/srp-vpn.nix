# TODO: to move in home/ with user in parameter
{ pkgs, ... }:
let
  hosts = import ../hosts.nix;
in
{
    users.users.${hosts.laptop-srp.user} = {
    packages = with pkgs; [
      openconnect_openssl
    ];
  };

   programs.zsh = {
    shellAliases = {
      vpnlogin = "sudo openconnect --user ext-c.prezelin --allow-insecure-crypto --background --pid-file $XDG_RUNTIME_DIR/openconnect-srp.pid --server vpn.showroomprive.fr/+webvpn+/index.html";
      vpnlogout = "sudo kill -9 $(cat $XDG_RUNTIME_DIR/openconnect-srp.pid)";
    };
  };

}
