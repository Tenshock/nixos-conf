{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
    git = true;
  };

  programs.zsh = {
    shellAliases = {
      ls = "eza";
    };
  };
}
