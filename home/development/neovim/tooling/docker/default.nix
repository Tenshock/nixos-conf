{ pkgs, ... }:
{
  programs.lazyvim = {
    extraPackages = with pkgs; [
      docker-compose-language-service
      dockerfile-language-server
      hadolint
    ];

    extras.lang.docker.enable = true;
  };
}
