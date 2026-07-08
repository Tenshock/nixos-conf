{ pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;
      extraLuaPackages = ps: [ ps.magick ];
      extraPackages = with pkgs; [
        clang
        fd
        fzf
        ghostscript
        imagemagick
        mermaid-cli
        nil
        ripgrep
        statix
        sqlite
        tectonic
        tree-sitter
        unzip
      ];
      extraWrapperArgs = [
        "--set"
        "LD_LIBRARY_PATH"
        "${pkgs.sqlite.out}/lib"
        "--set"
        "CC"
        "${pkgs.clang}/bin/clang"
      ];
    };

    zsh.shellAliases = {
      v = "nvim";
      view = "nvim -R";
    };

    tmux.extraConfig = ''
      # For 3rd-image Neovim setup
      set -gq allow-passthrough on
      set -g visual-activity off
    '';
  };
}
