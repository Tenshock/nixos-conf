{ pkgs, ... }:
let
  hosts = import ../hosts.nix;
  user = hosts.laptop-srp.user;
in {
  imports =
    [
      ./hardware-configuration.nix
      ./hibernate.nix
      ./networking.nix
      ./swap.nix

      ../../nixos/hyprland.nix
      ../../nixos/i18n.nix
      ../../nixos/lid-behavior.nix
      ../../nixos/login-manager.nix
      ../../nixos/media.nix
      ../../nixos/neovim.nix
      ../../nixos/nix.nix
      ../../nixos/printing.nix
      ../../nixos/systemd-boot.nix
      (import ../../nixos/user.nix user)
      (import ../../nixos/virtualization.nix user)
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

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
