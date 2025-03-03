{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wget
    go        # Lazyvim: hyprland LSP hyprls
    fastfetch
  ];

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
