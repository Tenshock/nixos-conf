user:
{ pkgs, ... }: {
  users.users.${user} = { packages = with pkgs; [ kdePackages.dolphin ]; };
}
