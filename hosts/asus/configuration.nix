{ hostName, user }:
{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.monique.nixosModules.default

    ./hardware-configuration.nix
    (import ./networking.nix { inherit hostName user; })

    ../../flakes/catppuccin.nix
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

    ../../nixos/hardware/power-profiles-daemon.nix

    (import ../../nixos/programs/1password.nix user)
    ../../nixos/programs/cameractrls-gtk4.nix
    ../../nixos/programs/neovim.nix
    ../../nixos/programs/smile.nix
    ../../nixos/programs/tchap-desktop.nix
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
  services.hardware.bolt.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  users.users.${user} = {
    extraGroups = [ "docker" ];
    packages = [ pkgs.docker-compose ];
  };

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
