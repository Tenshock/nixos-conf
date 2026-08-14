user:
{ pkgs, ... }:
{
  imports = [
    ../../flakes/catppuccin.nix

    ../../flakes/chatgpt-desktop.nix
    ../../flakes/monique.nix

    ../../nixos/core/i18n.nix
    ../../nixos/core/nix.nix
    ../../nixos/core/systemd-boot.nix
    (import ../../nixos/core/user.nix user)

    ../../nixos/desktop/gpg-agent.nix
    ../../nixos/desktop/hyprland.nix
    ../../nixos/desktop/keyring.nix
    ../../nixos/desktop/login-manager.nix
    ../../nixos/desktop/media.nix
    ../../nixos/desktop/polkit.nix

    ../../nixos/hardware/fingerprint.nix
    ../../nixos/hardware/hibernation.nix
    ../../nixos/hardware/nvidia.nix
    ../../nixos/hardware/power-profiles-daemon.nix
    ../../nixos/hardware/zswap.nix

    (import ../../nixos/programs/1password.nix user)
    ../../nixos/programs/cameractrls-gtk4.nix
    ../../nixos/programs/mattermost.nix
    (import ../../nixos/programs/minecraft.nix user)
    ../../nixos/programs/neovim.nix
    ../../nixos/programs/nvbroadcast.nix
    ../../nixos/programs/smile.nix
    ../../nixos/programs/steam.nix
    ../../nixos/programs/tchap-desktop.nix
    (import ../../nixos/programs/thunar.nix user)

    ../../nixos/services/printing.nix
    (import ../../nixos/services/virtualization.nix user)
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

  #####################

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
