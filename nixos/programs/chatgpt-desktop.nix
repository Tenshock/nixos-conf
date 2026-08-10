{ inputs, ... }:

{
  imports = [ inputs.chatgpt-desktop-linux.nixosModules.default ];

  programs.chatgptDesktop.enable = true;
}
