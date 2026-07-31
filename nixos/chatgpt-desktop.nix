{ inputs, ... }:

{
  imports = [ inputs.chatgpt-desktop-linux.nixosModules.default ];

  programs.chatgptDesktop = {
    enable = true;
    githubTokenCommand = [
      "/run/wrappers/bin/op"
      "read"
      "op://Personal/github.com/NixOS PAT"
    ];
  };
}
