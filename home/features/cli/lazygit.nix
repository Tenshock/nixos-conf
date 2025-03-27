{pkgs, config, ... }:
let
  mochaTheme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/lazygit/21a25afd92327ddea8446ab9171ca7039b431e9e/themes-mergable/mocha/yellow.yml";
    sha256 = "sha256-y7upf9Dt/FsXBFdohJxcST3GxmM0MFXQosBtBgJ0auM=";
  };
in {
  # TODO: make it standalone and automatically imported by neovim
  programs.lazygit = {
    enable = true;
    settings = {
      git.paging = {
        colorArg = "always";
        pager = ''delta --paging=never --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"'';
      };
    };
  };

  home = {
    file."${config.xdg.configHome}/lazygit/mocha.yml".source = mochaTheme;
    sessionVariables.LG_CONFIG_FILE = let
      lazygitConfig = "${config.xdg.configHome}/lazygit";
    in
      "${lazygitConfig}/config.yml,${lazygitConfig}/mocha.yml";
  };

  programs.zsh.shellAliases.lg = "lazygit";
}
