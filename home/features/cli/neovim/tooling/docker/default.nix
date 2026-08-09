{ pkgs, ... }:
{
  programs.neovim.extraPackages = with pkgs; [
    docker-compose-language-service
    dockerfile-language-server
    hadolint
  ];

  xdg.configFile."nvim/lua/tooling-extras/docker.lua".source = ./extras.lua;
}
