# TODO: currying hostname and user
let hosts = import ../hosts.nix;
in {
  networking.hostName = hosts.macbook-seekube.hostname;
}
