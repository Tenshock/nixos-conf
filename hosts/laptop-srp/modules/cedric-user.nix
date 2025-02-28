# TODO: move into nixos with user in parameter
{ pkgs, ... }:
let
  hosts = import ../../hosts.nix;
in
{
  users.users.${hosts.laptop-srp.user} = {
    isNormalUser = true;
    description = hosts.laptop-srp.user;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      firefox
      obsidian
      dotnet-sdk_9
      csharpier
      webcord
      appimage-run
    ];
  };

  environment.variables = {
    XDG_CONFIG_HOME = "/home/cedric/.config";
    XDG_DATA_HOME = "/home/cedric/.local/share";
    XDG_STATE_HOME = "/home/cedric/.local/state";
  };
}
