user: { inputs, lib, ... }: {
  imports = [
    inputs.zen-browser.homeModules.twilight
    ../../darwin/macos-app-link-fix.nix

    ../../home/features/application/google-chrome.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/mongodb-compass.nix
    ../../home/features/application/notion.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/postman.nix
    ../../home/features/application/slack.nix

    ../../home/features/prog-lang/go.nix
    ../../home/features/prog-lang/node.nix
    ../../home/features/prog-lang/rust.nix

    ../../home/features/service/ssh.nix
    ../../home/features/service/xdg.nix

    ../../home/features/cli/atuin.nix
    ../../home/features/cli/awscli.nix
    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix
    ../../home/features/cli/cocogitto.nix
    ../../home/features/cli/codex
    ../../home/features/cli/eza.nix
    ../../home/features/cli/fastfetch.nix
    ../../home/features/cli/fzf.nix
    ../../home/features/cli/gcloud.nix
    ../../home/features/cli/jq-yq.nix
    ../../home/features/cli/git
    ../../home/features/cli/k9s.nix
    ../../home/features/cli/lazygit.nix
    ../../home/features/cli/less.nix
    ../../home/features/cli/mongosh.nix
    ../../home/features/cli/nh.nix
    ../../home/features/cli/starship.nix
    ../../home/features/cli/uncompress.nix
    ../../home/features/cli/neovim.nix
    ../../home/features/cli/qlty.nix
    ../../home/features/cli/tmux
    ../../home/features/cli/wget.nix
    ../../home/features/cli/zoxide.nix
    ../../home/features/cli/zsh.nix

    ../../home/features/fonts/nerd.nix

    ../../catppuccin.nix
  ];

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
    preferXdgDirectories = true;
    stateVersion = "26.05";
  };
}
