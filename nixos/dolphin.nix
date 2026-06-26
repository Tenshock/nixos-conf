user:
{ pkgs, ... }:
let
  xdgApplicationsMenu = pkgs.writeTextDir "etc/xdg/menus/applications.menu" ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <Include>
        <All/>
      </Include>
    </Menu>
  '';
in
{
  users.users.${user} = {
    packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.kservice
      xdgApplicationsMenu
    ];
  };
}
