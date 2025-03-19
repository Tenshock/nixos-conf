{ pkgs, ... }: {
  ## TODO: switch to nixvim?

  home.packages = with pkgs; [
    nodejs_23 # Lazyvim
    clang     # for nil
    go        # Lazyvim: hyprland LSP hyprls
    fzf
    ripgrep
    unzip
    fd
    rustup    # Lazyvim
    dotnet-sdk_9
    csharpier # for omnisharp lazyvim extra, see nvim/lua/plugins/conform.lua
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = [ pkgs.imagemagick ];
  };

  programs.zsh.shellAliases = {
    v = "nvim";
    view = "nvim -R";
  };

  programs.tmux.extraConfig = ''
    # For 3rd-image Neovim setup
    set -gq allow-passthrough on
    set -g visual-activity off
  '';
}
