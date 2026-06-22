{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#7f849c";
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
    ];
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "tmux"
        "git"
      ];
    };

    # macOS-only init: make SDKROOT/LIBRARY_PATH available
    initContent = lib.mkIf pkgs.stdenv.isDarwin ''
      # Only for interactive shells, and only if xcrun is available
      if [[ $- == *i* ]] && command -v xcrun >/dev/null 2>&1; then
        export SDKROOT="$(xcrun --show-sdk-path)"
        export LIBRARY_PATH="$SDKROOT/usr/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}"
      fi

      # nvm
      export NVM_DIR="$HOME/.nvm"
      [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
      [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
    '';
  };
}
