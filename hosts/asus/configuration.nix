{ hostName, user }:
{ config, pkgs, ... }:
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
  services.xserver.videoDrivers = [ "nvidia" ];

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/eda0fb17-411c-4cf3-b861-67d221267e01";
    fsType = "ext4";
    options = [
      "nofail"
      "x-gvfs-show"
    ];
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  system.stateVersion = "26.05";
}
