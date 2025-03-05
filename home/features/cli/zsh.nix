{ config, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh"; # Relative path. Can't use config.xdg.configHome.
    shellAliases = {
      v = "nvim";
      view = "nvim -R";
      nix-conf = "nvim $XDG_CONFIG_HOME/nixos";
      hypr-conf = "nvim $XDG_CONFIG_HOME/hypr/hyprland.conf";
    };
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#7f849c";
    };
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
