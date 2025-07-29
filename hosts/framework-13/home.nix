let
  hosts = import ../hosts.nix;
in {
  imports = [
    ../../home/features/application/beeper.nix
    ../../home/features/application/browser.nix
    ../../home/features/application/dbeaver.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/mongodb-compass.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/slack.nix
    ../../home/features/application/teams.nix
    ../../home/features/application/transmission.nix
    ../../home/features/application/vlc.nix
    ../../home/features/application/webcord.nix

    ../../home/features/cli/udiskie.nix

    ../../home/features/prog-lang/dotnet.nix
    ../../home/features/prog-lang/go.nix
    ../../home/features/prog-lang/node.nix
    ../../home/features/prog-lang/rust.nix

    ../../home/flavors/minimal.nix
    ../../home/flavors/hyprland.nix
  ];

  home = {
    username = hosts.framework-13.user;
    homeDirectory = "/home/${hosts.framework-13.user}";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    stateVersion = "25.05";
  };
}
