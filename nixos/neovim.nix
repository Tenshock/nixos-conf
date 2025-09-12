{ pkgs, ... }: {
  # enable auto-generated scripts for neovim
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [ icu ];
}
