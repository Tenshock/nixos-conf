{
  inputs,
  pkgs,
  ...
}:
let
  appName = "lazyvim";

  mkInputPlugin =
    {
      pname,
      src,
      nvimSkipModules ? [ ],
    }:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src nvimSkipModules;
      version = src.shortRev or "unstable";
    };

  customPlugins = {
    auto-save-nvim = pkgs.vimPlugins.auto-save-nvim;
    catppuccin-nvim = pkgs.vimPlugins.catppuccin-nvim;
    material-nvim = pkgs.vimPlugins.material-nvim;
    lazy-nvim = pkgs.vimPlugins.lazy-nvim;
    mini-cursorword = pkgs.vimPlugins.mini-cursorword;
    neo-tree-nvim = pkgs.vimPlugins.neo-tree-nvim;
    smart-splits-nvim = pkgs.vimPlugins.smart-splits-nvim;

    neotest-nodejs = mkInputPlugin {
      pname = "neotest-nodejs";
      src = inputs.neotest-nodejs;
      nvimSkipModules = [
        "neotest-nodejs"
        "neotest-nodejs.node-util"
        "neotest-nodejs.util"
        "neotest-nodejs-assertions"
      ];
    };
    neotest-vstest = mkInputPlugin {
      pname = "neotest-vstest";
      src = inputs.neotest-vstest;
      nvimSkipModules = [
        "repro"
        "neotest-vstest.dotnet_utils"
        "neotest-vstest.utilities"
        "neotest-vstest.strategies.vstest"
        "neotest-vstest.strategies.vstest_debugger"
        "neotest-vstest.files"
        "neotest-vstest.client"
        "neotest-vstest"
        "neotest-vstest.vstest.client"
        "neotest-vstest.vstest.init"
        "neotest-vstest.vstest.cli_wrapper"
        "neotest-vstest.mtp.client"
        "neotest-vstest.mtp.init"
      ];
    };
    telescope-terraform-doc-nvim = mkInputPlugin {
      pname = "telescope-terraform-doc.nvim";
      src = inputs.telescope-terraform-doc-nvim;
    };
    telescope-terraform-nvim = mkInputPlugin {
      pname = "telescope-terraform.nvim";
      src = inputs.telescope-terraform-nvim;
    };
  };

  pinPlugin =
    plugin: package: file:
    builtins.replaceStrings
      [ "\"${plugin}\"" ]
      [
        ''"${plugin}", dir = "${package}"''
      ]
      (builtins.readFile file);
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

  _module.args.lazyvimCustomPlugins = customPlugins;

  programs = {
    lazyvim = {
      enable = true;
      inherit appName;
      pluginSource = "latest";
      installCoreDependencies = false;
      ignoreBuildNotifications = true;
      config = {
        keymaps = builtins.readFile ./config/lua/keymaps.lua;
        options = builtins.readFile ./config/lua/options.lua;
      };
      extras = {
        coding = {
          blink.enable = true;
          mini-surround.enable = true;
        };
        dap.core.enable = true;
        editor = {
          harpoon2.enable = true;
          refactoring.enable = true;
          neo-tree.enable = true;
          snacks-picker.enable = true;
        };
        lang.git.enable = true;
        test.core.enable = true;
      };
      plugins = {
        autosave = pinPlugin "okuuva/auto-save.nvim" customPlugins.auto-save-nvim ./plugins/autosave.lua;
        blink-cmp = builtins.readFile ./plugins/blink-cmp.lua;
        bufferline = builtins.readFile ./plugins/bufferline.lua;
        sidekick = pinPlugin "folke/sidekick.nvim" pkgs.vimPlugins.sidekick-nvim ./plugins/sidekick.lua;
        colorscheme =
          pinPlugin "marko-cerovac/material.nvim" customPlugins.material-nvim
            ./plugins/colorscheme.lua;
        json = builtins.readFile ./plugins/json.lua;
        leetcode = pinPlugin "kawre/leetcode.nvim" pkgs.vimPlugins.leetcode-nvim ./plugins/leetcode.lua;
        lualine = builtins.readFile ./plugins/lualine.lua;
        mason = builtins.readFile ./plugins/mason.lua;
        mini-cursorword =
          pinPlugin "nvim-mini/mini.cursorword" customPlugins.mini-cursorword
            ./plugins/mini-cursorword.lua;
        neo-tree = builtins.readFile ./plugins/neo-tree.lua;
        smart-splits =
          pinPlugin "mrjones2014/smart-splits.nvim" customPlugins.smart-splits-nvim
            ./plugins/smart-splits.lua;
        snacks = builtins.readFile ./plugins/snacks.lua;
        nix-plugin-dirs = ''
          return {
            { "saghen/blink.cmp", dir = "${pkgs.vimPlugins.blink-cmp}" },
            { name = "catppuccin", dir = "${customPlugins.catppuccin-nvim}" },
            { "rafamadriz/friendly-snippets", dir = "${pkgs.vimPlugins.friendly-snippets}" },
            { name = "lazy.nvim", dir = "${customPlugins.lazy-nvim}", dev = false },
            { "nvim-neo-tree/neo-tree.nvim", dir = "${customPlugins.neo-tree-nvim}" },
            { "fredrikaverpil/neotest-golang", dir = "${pkgs.vimPlugins.neotest-golang}" },
            { "nvim-neotest/neotest-python", dir = "${pkgs.vimPlugins.neotest-python}" },
            { "Nsidorenco/neotest-vstest", dir = "${customPlugins.neotest-vstest}" },
            { "leoluz/nvim-dap-go", dir = "${pkgs.vimPlugins.nvim-dap-go}" },
            { "mfussenegger/nvim-dap-python", dir = "${pkgs.vimPlugins.nvim-dap-python}" },
            { "theHamsta/nvim-dap-virtual-text", dir = "${pkgs.vimPlugins.nvim-dap-virtual-text}" },
            { "nvim-neotest/nvim-nio", dir = "${pkgs.vimPlugins.nvim-nio}" },
            { "ANGkeith/telescope-terraform-doc.nvim", dir = "${customPlugins.telescope-terraform-doc-nvim}" },
            { "cappyzawa/telescope-terraform.nvim", dir = "${customPlugins.telescope-terraform-nvim}" },
            { "nvim-telescope/telescope.nvim", dir = "${pkgs.vimPlugins.telescope-nvim}" },
          }
        '';
      };
      extraPackages = with pkgs; [
        clang
        codex
        curl
        fd
        fzf
        git
        lazygit
        ripgrep
        unzip
      ];
    };

    neovim = {
      defaultEditor = true;
      extraWrapperArgs = [
        "--set"
        "NVIM_APPNAME"
        appName
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

  xdg = {
    dataFile."${appName}/lazy/lazy.nvim" = {
      source = pkgs.vimPlugins.lazy-nvim;
      recursive = true;
    };

    configFile = {
      "${appName}/lazyvim.json".source = ./config/lazyvim.json;
      "${appName}/.neoconf.json".source = ./config/neoconf.json;
      "${appName}/stylua.toml".source = ./config/stylua.toml;
    };
  };
}
