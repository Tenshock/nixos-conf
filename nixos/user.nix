user: { pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
}
