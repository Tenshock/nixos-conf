{ pkgs, ... }:
{
  home.packages = with pkgs; [
    openconnect_openssl
  ];

  programs.zsh = {
    shellAliases = {
      vpnlogin = "sudo openconnect --user ext-c.prezelin --allow-insecure-crypto --background --pid-file $XDG_RUNTIME_DIR/openconnect-srp.pid --server vpn.showroomprive.fr/+webvpn+/index.html";
      vpnlogout = "sudo kill -9 $(cat $XDG_RUNTIME_DIR/openconnect-srp.pid)";
    };
  };
}
