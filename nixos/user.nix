{ user }:
{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      obsidian
      dotnet-sdk_9
      csharpier
      webcord
      appimage-run
    ];
    shell = pkgs.zsh;
  };

  environment.variables = {
    XDG_CONFIG_HOME = "/home/${user}/.config";
    XDG_DATA_HOME = "/home/${user}/.local/share";
    XDG_STATE_HOME = "/home/${user}/.local/state";
  };
}
