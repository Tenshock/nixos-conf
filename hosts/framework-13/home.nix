user:
{ ... }:
{
  imports = [
    ../../flakes/catppuccin.nix

    ../../home/options.nix

    ../../home/appearance/fonts.nix

    ../../home/applications/beeper.nix
    ../../home/applications/datagrip.nix
    ../../home/applications/discord.nix
    ../../home/applications/google-chrome.nix
    ../../home/applications/kitty
    ../../home/applications/loupe.nix
    ../../home/applications/mangohud.nix
    ../../home/applications/obsidian.nix
    ../../home/applications/onlyoffice.nix
    ../../home/applications/transmission.nix
    ../../home/applications/vlc.nix
    ../../home/applications/zen

    ../../home/desktop/awww.nix
    ../../home/desktop/gtk.nix
    ../../home/desktop/hyprcursor.nix
    ../../home/desktop/hypridle.nix
    ../../home/desktop/hyprland
    ../../home/desktop/hyprlock.nix
    ../../home/desktop/hyprpicker.nix
    ../../home/desktop/hyprshot.nix
    ../../home/desktop/hyprsunset.nix
    ../../home/desktop/power-menu.nix
    ../../home/desktop/stay-awake.nix
    ../../home/desktop/swaync
    ../../home/desktop/walker
    ../../home/desktop/waybar/waybar.nix
    ../../home/desktop/waycorner.nix
    ../../home/desktop/wl-clipboard.nix

    ../../home/development/codex
    ../../home/development/git
    ../../home/development/gh-cli.nix
    ../../home/development/helm.nix
    ../../home/development/k9s.nix
    ../../home/development/kubectl.nix
    ../../home/development/lazygit.nix
    ../../home/development/neovim
    ../../home/development/nh.nix
    ../../home/development/nix-index.nix
    ../../home/development/ripgrep.nix

    ../../home/services/1password.nix
    ../../home/services/easyeffects
    ../../home/services/ssh.nix
    ../../home/services/udiskie.nix
    ../../home/services/xdg.nix

    ../../home/shell/atuin.nix
    ../../home/shell/bat.nix
    ../../home/shell/btop.nix
    ../../home/shell/direnv.nix
    ../../home/shell/eza.nix
    ../../home/shell/fastfetch.nix
    ../../home/shell/fzf.nix
    ../../home/shell/jq-yq.nix
    ../../home/shell/starship.nix
    ../../home/shell/uncompress.nix
    ../../home/shell/wget.nix
    ../../home/shell/zoxide.nix
    ../../home/shell/zsh.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    preferXdgDirectories = true;
    sessionPath = [ "$HOME/.local/bin" ];
    stateVersion = "26.05";
  };

}
