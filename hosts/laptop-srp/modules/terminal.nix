{ pkgs, ... }: {
  users.users.cedric = {
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    wget
    git
    go        # Lazyvim: hyprland LSP hyprls
    eza
    bat
    zoxide
    fastfetch
    btop
    cava      # audio flex
    cbonsai
    yazi      # fileManager
  ];

  programs.zsh = {
    enable = true;
    shellInit= ''eval "$(zoxide init zsh)"'';
    shellAliases = {
      v = "nvim";
      view = "nvim -R";
      cd = "z";
      ls = "eza";
      cat = "bat";
      nix-conf = "sudo -E nvim /etc/nixos";
      hypr-conf = "nvim $XDG_CONFIG_HOME/hypr/hyprland.conf";
    };
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      theme = "bira";
      plugins = [
        "tmux"
        "git"
      ];
    };
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      run-shell ${pkgs.tmuxPlugins.battery}/share/tmux-plugins/tmux-battery/battery.tmux
    '';
  };


  # zsh XDG compliance
  environment.etc."zshenv".text = ''
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
    export ZSH_TMUX_AUTOSTART=true
    export ZSH_TMUX_AUTOCONNECT=false
  '';
}
