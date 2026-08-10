user:
{ pkgs, ... }:
{
  users.users.${user} = {
    packages = with pkgs; [
      thunar
    ];
  };

  services.tumbler.enable = true;
}
