{
  config,
  lib,
  pkgs,
  ...
}:
let
  lazyLockPath = "${config.dotfiles.repositoryRoot}/home/features/cli/neovim/lazy-lock.json";
in
{
  imports = [
    ./tooling/docker
    ./tooling/hyprland
    ./tooling/js-ts
    ./tooling/lua.nix
    ./tooling/markdown
    ./tooling/nix
    ./tooling/python
    ./tooling/shell
    ./tooling/sql
    ./tooling/toml
    ./tooling/typst
    ./tooling/yaml
  ];

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      sideloadInitLua = true;
      initLua = lib.mkAfter (builtins.readFile ./config/init.lua);
      extraPackages = with pkgs; [
        clang
        fd
        fzf
        ripgrep
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

    tmux.extraConfig =
      # bash
      ''
        # For 3rd-image Neovim setup
        set -gq allow-passthrough on
        set -g visual-activity off
      '';
  };

  assertions = [
    {
      assertion = builtins.pathExists lazyLockPath;
      message = "Neovim lazy.nvim lock file does not exist: ${lazyLockPath}";
    }
  ];

  xdg.configFile = {
    "nvim/lazyvim.json".source = ./config/lazyvim.json;
    "nvim/.neoconf.json".source = ./config/neoconf.json;
    "nvim/stylua.toml".source = ./config/stylua.toml;

    "nvim/lua/config" = {
      source = ./config/lua;
      recursive = true;
    };
    "nvim/lua/plugins" = {
      source = ./plugins;
      recursive = true;
    };

    # lazy.nvim must be able to update its canonical lock file.
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink lazyLockPath;
  };
}
