{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      ...
    }@inputs:

    let
      hosts = import ./hosts/hosts.nix;

      mkNixOSConfiguration =
        {
          host,
          nixpkgs,
          home-manager,
        }:
      nixpkgs.lib.nixosSystem {
          system = host.arch;
          modules = [
            ./hosts/${host.dir}/configuration.nix
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
    in

    {
      nixosConfigurations."${hosts.laptop-srp.hostname}" = mkNixOSConfiguration {
        host = hosts.laptop-srp;
        nixpkgs = inputs.nixpkgs;
        home-manager = inputs.home-manager;
      };
    };
}
