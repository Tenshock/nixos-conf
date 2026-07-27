user:
{ pkgs, ... }:
{
  imports = [
    (import ../../nixos/1password.nix user)
    ../../nixos/cameractrls-gtk4.nix
    ../../catppuccin.nix
    (import ../../nixos/thunar.nix user)
    ../../nixos/fingerprint.nix
    ../../nixos/hibernation.nix
    ../../nixos/hyprland.nix
    ../../nixos/i18n.nix
    ../../nixos/gpg-agent.nix
    ../../nixos/keyring.nix
    ../../nixos/login-manager.nix
    ../../nixos/mattermost.nix
    ../../nixos/media.nix
    (import ../../nixos/minecraft.nix user)
    ../../nixos/neovim.nix
    ../../nixos/nvbroadcast.nix
    ../../nixos/nvidia.nix
    ../../nixos/obs-studio.nix
    ../../nixos/nix.nix
    ../../nixos/polkit.nix
    ../../nixos/printing.nix
    ../../nixos/smile.nix
    ../../nixos/steam.nix
    ../../nixos/systemd-boot.nix
    ../../nixos/power-profiles-daemon.nix
    (import ../../nixos/user.nix user)
    (import ../../nixos/virtualization.nix user)
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "i2c-dev" ];
  };

  services = {
    fwupd.enable = true;
    hardware.bolt.enable = true;
    udev.extraRules = ''
      SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ATTRS{vendor}=="0x1002", ATTRS{device}=="0x150e", SYMLINK+="dri/amd-igpu"
      SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ATTRS{vendor}=="0x10de", ATTRS{device}=="0x2f04", SYMLINK+="dri/nvidia-egpu"
      KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    '';
  };

  environment.systemPackages = with pkgs; [
    brightnessctl # enables hotkey brightness control
    ddcutil
  ];

  programs.monique.enable = true;

  #####################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
