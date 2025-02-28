{
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    shellAliases = {
      v = "nvim";
      view = "nvim -R";
      cd = "z";
      ls = "eza";
      cat = "bat";
      nix-conf = "nvim $XDG_CONFIG_HOME/nixos";
      hypr-conf = "nvim $XDG_CONFIG_HOME/hypr/hyprland.conf";
    };
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "bira";
      plugins = [
        "tmux"
        "git"
      ];
    };
  };
}
