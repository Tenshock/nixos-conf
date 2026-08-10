{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mattermost-desktop
  ];
}
