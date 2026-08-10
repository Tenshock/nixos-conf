user: { pkgs, ... }: {
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [
      "wheel"
      "lpadmin"
      "i2c"
    ];
    shell = pkgs.zsh;
  };

  users.groups.i2c = { };
}
