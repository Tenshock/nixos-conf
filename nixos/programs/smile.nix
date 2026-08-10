{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    smile
  ];
}
