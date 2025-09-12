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
      mkDarwinConfigurations = { host, nixpkgs, nix-darwin, home-manager, }:
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
              users.users.cprezelin.home = "/Users/${hosts.hw-macbook.user}";
            }
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
        };
    };
}
