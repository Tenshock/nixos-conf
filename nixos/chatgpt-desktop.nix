{ dependencies, ... }:

{
  imports = [ dependencies.nixosModules.chatgptDesktop ];

  programs.chatgptDesktop.enable = true;
}
