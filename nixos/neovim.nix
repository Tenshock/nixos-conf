{ pkgs, ... }: {
  # enable auto-generated scripts for neovim
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ icu ];
  };
}
