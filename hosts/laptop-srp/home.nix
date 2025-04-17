let
  hosts = import ../hosts.nix;
in {
  imports = [
    ../../home/features/application/beeper.nix
    ../../home/features/application/browser.nix
    ../../home/features/application/kitty.nix
    ../../home/features/application/obsidian.nix
    ../../home/features/application/teams.nix
    ../../home/features/application/webcord.nix

    ../../home/features/cli/udiskie.nix

    ../../home/features/service/srp-vpn.nix

    ../../home/features/prog-lang/dotnet.nix
    ../../home/features/prog-lang/go.nix
    ../../home/features/prog-lang/node.nix
    ../../home/features/prog-lang/rust.nix

    ../../home/flavors/minimal.nix
    ../../home/flavors/hyprland.nix
  ];

  home = {
    username = hosts.laptop-srp.user;
    homeDirectory = "/home/${hosts.laptop-srp.user}";
    sessionPath = [
      "$HOME/.local/bin"
    ];
    stateVersion = "24.11";
  };
}
