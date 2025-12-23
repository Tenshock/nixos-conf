{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

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

      mkNixOSConfiguration = { host, nixpkgs, nixos-hardware, home-manager, }:
        nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            (import ./hosts/${host.dir}/configuration.nix host.user)
            nixos-hardware.nixosModules.framework-amd-ai-300-series
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users."${host.user}" =
                  (import ./hosts/${host.dir}/home.nix host.user);
              };
            }
          ];
        };
      mkDarwinConfigurations = { host, nix-darwin, home-manager, nix-homebrew
        , homebrew-core, homebrew-cask }:
        nix-darwin.lib.darwinSystem {
          system = host.arch;
          modules = [
            (import ./hosts/${host.dir}/configuration.nix host.user)
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users."${host.user}" =
                  (import ./hosts/${host.dir}/home.nix host.user);
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
            ({ config, ... }: {
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
      darwinConfigurations."${hosts.macbook-seekube.hostname}" =
        mkDarwinConfigurations {
          host = hosts.macbook-seekube;
          nix-darwin = inputs.nix-darwin;
          home-manager = inputs.home-manager;
          nix-homebrew = inputs.nix-homebrew;
          homebrew-core = inputs.homebrew-core;
          homebrew-cask = inputs.homebrew-cask;
        };
    };
}
