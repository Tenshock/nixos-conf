{ user }:
{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      # TODO: move this
      dotnet-sdk_9
      csharpier
      webcord
      appimage-run
    ];
    shell = pkgs.zsh;
  };
}
