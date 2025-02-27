{ ... }:

{
  imports =
    [
      ./modules/cedric-user.nix
      ./modules/fonts.nix
      ./hardware-configuration.nix
      ./modules/host-networking.nix
      ./modules/host-srp.nix
      ./modules/hyprland.nix
      ./modules/i18n.nix
      ./modules/login-manager.nix
      ./modules/media.nix
      ./modules/neovim.nix
      ./modules/nix.nix
      ./modules/terminal.nix
      ./modules/virtualization.nix
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
