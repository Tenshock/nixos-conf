{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs:

    let
      hosts = import ./hosts/hosts.nix;

      mkNixOSConfiguration = { host, nixpkgs, nixos-hardware, home-manager, }:
        nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
            nixos-hardware.nixosModules.framework-amd-ai-300-series
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${host.user}" = import ./hosts/${host.dir}/home.nix;
              };
            }
          ];
        };
      mkDarwinConfigurations = { host, nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, }:
        nix-darwin.lib.darwinSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users."${host.user}" = import ./hosts/${host.dir}/home.nix;
              };
              users.users.${host.user}.home = "/Users/${host.user}";
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = host.user;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };

                mutableTaps = false;
              };
            }
            ({config, ...}: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
          ];
        };

    in {
      nixosConfigurations."${hosts.framework-13.hostname}" =
        mkNixOSConfiguration {
          host = hosts.framework-13;
          nixpkgs = inputs.nixpkgs;
          nixos-hardware = inputs.nixos-hardware;
          home-manager = inputs.home-manager;
        };
      darwinConfigurations."${hosts.hw-macbook.hostname}" =
        mkDarwinConfigurations {
          host = hosts.hw-macbook;
          nixpkgs = inputs.nixpkgs;
          nix-darwin = inputs.nix-darwin;
          home-manager = inputs.home-manager;
          nix-homebrew = inputs.nix-homebrew;
          homebrew-core = inputs.homebrew-core;
          homebrew-cask = inputs.homebrew-cask;
        };
    };
}
