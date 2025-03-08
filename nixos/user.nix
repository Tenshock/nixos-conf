user:
{ pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      appimage-run
    ];
    shell = pkgs.zsh;
  };
}
