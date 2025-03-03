{ pkgs, ... }:
let
  hosts = import ../hosts.nix;
in {
  imports =
    [
      ./hardware-configuration.nix
      ./hibernate.nix
      ./networking.nix
      ./swap.nix

      ./modules/hyprland.nix
      ./modules/neovim.nix

      ../../nixos/i18n.nix
      ../../nixos/login-manager.nix
      ../../nixos/media.nix
      ../../nixos/nix.nix
      (import ../../nixos/user.nix { user = hosts.laptop-srp.user; })
      ../../nixos/virtualization.nix
      # TODO: add nwg-displays, check for home-manager integration
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    brightnessctl # enables hotkey brightness control
  ];

  #####################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
