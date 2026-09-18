{ hostName, user }:
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    (import ./networking.nix { inherit hostName user; })

    ../../flakes/catppuccin.nix

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

    ../../nixos/hardware/power-profiles-daemon.nix

    (import ../../nixos/programs/1password.nix user)
    ../../nixos/programs/neovim.nix
    (import ../../nixos/programs/thunar.nix user)
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  system.stateVersion = "26.05";
}
