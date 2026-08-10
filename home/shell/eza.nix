{
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "always";
    git = true;
  };

  programs.zsh.shellAliases = {
    l = "eza -lh";
    lt = "eza -lhTL";
    la = "eza -alh";
    lta = "eza -alhTL";
  };
}
