{ pkgs, ... }: {
  ## TODO: switch to nixvim?

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaPackages = ps: [ ps.magick ];
    extraPackages = with pkgs; [
      clang
      csharpier
      nodejs_23
      dotnet-sdk_9
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
      unzip
    ];
    extraWrapperArgs = [
      "--set" "LD_LIBRARY_PATH" "${pkgs.sqlite.out}/lib"
    ];
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
