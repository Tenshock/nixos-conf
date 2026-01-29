{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    initLua = ''
      require("config.lazy")
    '';
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = with pkgs; [
      clang
      # csharpier
      nodejs_24
      fd
      fzf
      ghostscript
      go
      imagemagick
      mermaid-cli
      ripgrep
      rustup
      sqlite
      tectonic
      tree-sitter
      unzip
    ];
    extraWrapperArgs = [ "--set" "LD_LIBRARY_PATH" "${pkgs.sqlite.out}/lib" ];
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
