{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { self, ... }@inputs:

    let
      hosts = import ./hosts/hosts.nix;

      mkNixOSConfiguration =
        { host, nixpkgs, nixos-hardware, home-manager, catppuccin }:
        nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            (import ./hosts/${host.dir}/configuration.nix host.user)
            ./hosts/${host.dir}/hardware-configuration.nix
            (import ./hosts/${host.dir}/networking.nix {
              hostName = host.hostname;
              inherit (host) user;
            })
            nixos-hardware.nixosModules.framework-amd-ai-300-series
            home-manager.nixosModules.home-manager
            catppuccin.nixosModules.catppuccin
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users."${host.user}" = {
                  imports = [
                    (import ./hosts/${host.dir}/home.nix host.user)
                    catppuccin.homeModules.catppuccin
                  ];
                };
              };
            }
          ];
        };
      mkDarwinConfigurations = { host, nix-darwin, home-manager, nix-homebrew
        , homebrew-core, homebrew-cask, catppuccin }:
        nix-darwin.lib.darwinSystem {
          system = host.arch;
          modules = [
            (import ./hosts/${host.dir}/configuration.nix host.user)
            (import ./hosts/${host.dir}/networking.nix host.hostname)
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users."${host.user}" = {
                  imports = [
                    (import ./hosts/${host.dir}/home.nix host.user)
                    catppuccin.homeModules.catppuccin
                  ];
                };
              };
              users.users.${host.user}.home = "/Users/${host.user}";
            }
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                inherit (host) user;

                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };

                mutableTaps = false;
              };
            }
            ({ config, ... }: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
          ];
        };

    in {
      nixosConfigurations."${hosts.framework-13.hostname}" =
        mkNixOSConfiguration {
          host = hosts.framework-13;
          inherit (inputs) nixos;
          inherit (inputs) nixos-hardware;
          inherit (inputs) home-manager;
          inherit (inputs) catppuccin;
        };
      darwinConfigurations."${hosts.macbook-seekube.hostname}" =
        mkDarwinConfigurations {
          host = hosts.macbook-seekube;
          inherit (inputs) nix-darwin;
          inherit (inputs) home-manager;
          inherit (inputs) nix-homebrew;
          inherit (inputs) homebrew-core;
          inherit (inputs) homebrew-cask;
          inherit (inputs) catppuccin;
        };
    };
}
