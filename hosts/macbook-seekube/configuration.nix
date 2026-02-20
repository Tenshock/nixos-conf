user: {pkgs, ...}: {

  imports = [
    ../../darwin/1password.nix
    ../../darwin/aerospace.nix
    (import ../../darwin/dock.nix user)
    ../../darwin/homebrew.nix
    ../../darwin/hot-corners.nix
    ../../darwin/nix.nix
    ../../darwin/security.nix
    ../../darwin/trackpad.nix
    ../../darwin/wallpaper.nix
  ];

  nix.settings.experimental-features = "nix-command flakes";

  system = {
    primaryUser = user;
    stateVersion = 6;
    activationScripts = {
      rosettaInstall.text = ''
        softwareupdate --install-rosetta --agree-to-license
      '';
    };
  };



  nixpkgs.hostPlatform = "aarch64-darwin";
}
