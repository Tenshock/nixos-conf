user:
{ inputs, ... }:
{
  imports = [
    ../../home/features/application/beeper.nix
    ../../home/features/application/datagrip.nix
    ../../home/features/application/discord.nix
    ../../home/features/application/google-chrome.nix
    ../../home/features/application/kitty
    ../../home/features/application/loupe.nix
    ../../home/features/application/mangohud.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/onlyoffice.nix
    ../../home/features/application/transmission.nix
    ../../home/features/application/vlc.nix
    ../../home/features/application/zen

    ../../home/features/cli/atuin.nix
    ../../home/features/cli/bat.nix
    ../../home/features/cli/btop.nix
    ../../home/features/cli/codex
    ../../home/features/cli/direnv.nix
    ../../home/features/cli/eza.nix
    ../../home/features/cli/fastfetch.nix
    ../../home/features/cli/fzf.nix
    ../../home/features/cli/helm.nix
    ../../home/features/cli/jq-yq.nix
    ../../home/features/cli/git
    ../../home/features/cli/gh-cli.nix
    ../../home/features/cli/k9s.nix
    ../../home/features/cli/kubectl.nix
    ../../home/features/cli/lazygit.nix
    ../../home/features/cli/nh.nix
    ../../home/features/cli/nix-index.nix
    ../../home/features/cli/qlty.nix
    ../../home/features/cli/ripgrep.nix
    ../../home/features/cli/starship.nix
    ../../home/features/cli/stay-awake.nix
    ../../home/features/cli/uncompress.nix
    ../../home/features/cli/neovim.nix
    ../../home/features/cli/udiskie.nix
    ../../home/features/cli/wget.nix
    ../../home/features/cli/zoxide.nix
    ../../home/features/cli/zsh.nix

    ../../home/features/fonts/nerd.nix

    ../../home/features/service/ssh.nix
    ../../home/features/service/xdg.nix

    ../../home/flavors/hyprland.nix

    ../../catppuccin.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    preferXdgDirectories = true;
    sessionPath = [ "$HOME/.local/bin" ];
    stateVersion = "26.05";
  };

}
