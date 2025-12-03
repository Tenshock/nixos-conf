user: {lib, ...}: {
  imports = [
    ./macos-app-link-fix.nix

    ../../home/features/application/dbeaver.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/transmission.nix

    ../../home/features/prog-lang/go.nix
    ../../home/features/prog-lang/node.nix
    ../../home/features/prog-lang/rust.nix

    ../../home/features/service/ssh.nix
    ../../home/features/service/xdg.nix

    ../../home/features/cli/atuin.nix
    ../../home/features/cli/awscli.nix
    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix
    ../../home/features/cli/cbonsai.nix
    ../../home/features/cli/eza.nix
    ../../home/features/cli/fastfetch.nix
    ../../home/features/cli/fzf.nix
    ../../home/features/cli/git
    ../../home/features/cli/k9s.nix
    ../../home/features/cli/lazygit.nix
    ../../home/features/cli/less.nix
    ../../home/features/cli/nh.nix
    ../../home/features/cli/starship.nix
    ../../home/features/cli/unzip.nix
    ../../home/features/cli/neovim.nix
    ../../home/features/cli/tmux
    ../../home/features/cli/wget.nix
    ../../home/features/cli/zoxide.nix
    ../../home/features/cli/zsh.nix

    ../../home/features/fonts/nerd.nix

  ];

  home = {
    username = user;
    homeDirectory = "/Users/${user}";
    stateVersion = "25.11";
  };
}
