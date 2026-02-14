{
  # TODO: make it standalone and automatically imported by neovim
  programs.lazygit = {
    enable = true;
    settings = {
      git.pagers = [{
        pager = ''
          delta --paging=never --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"'';
        colorArg = "always";
      }];
    };
  };

  programs.zsh.shellAliases.lg = "lazygit";
}
