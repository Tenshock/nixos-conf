user:
{ inputs, ... }: {
  imports = [
    inputs.zen-browser.homeModules.twilight
    ../../home/features/application/beeper.nix
    ../../home/features/application/dbeaver.nix
    ../../home/features/application/discord.nix
    ../../home/features/application/firefox.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/mongodb-compass.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/slack.nix
    ../../home/features/application/transmission.nix
    ../../home/features/application/vlc.nix
    ../../home/features/application/zen.nix

    ../../home/features/cli/udiskie.nix
    ../../home/features/cli/codex.nix

    ../../home/features/prog-lang/go.nix
    ../../home/features/prog-lang/node.nix
    ../../home/features/prog-lang/python3.nix
    ../../home/features/prog-lang/rust.nix

    ../../home/features/service/ssh.nix

    ../../home/flavors/minimal.nix
    ../../home/flavors/hyprland.nix
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    sessionPath = [ "$HOME/.local/bin" ];
    stateVersion = "25.05";
  };
}
