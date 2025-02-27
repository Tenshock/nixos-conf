
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs_23 # Lazyvim
    clang     # for nil
    fzf
    ripgrep
    unzip
    lazygit
    fd
    rustup    # Lazyvim
    go        # Lazyvim: hyprland LSP hyprls
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
