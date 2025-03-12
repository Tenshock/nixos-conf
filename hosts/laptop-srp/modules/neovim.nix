{ pkgs, ... }: {
  programs.zsh.shellAliases = {
      v = "nvim";
      view = "nvim -R";
  };

  environment.systemPackages = with pkgs; [
    nodejs_23 # Lazyvim
    clang     # for nil
    go        # Lazyvim: hyprland LSP hyprls
    fzf
    ripgrep
    unzip
    lazygit
    fd
    rustup    # Lazyvim
    dotnet-sdk_9
    csharpier # for omnisharp lazyvim extra
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # enable auto-generated scripts for neovim
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    icu
  ];
}
