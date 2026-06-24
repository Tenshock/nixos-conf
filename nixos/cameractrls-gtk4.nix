{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cameractrls-gtk4
  ];
}
