{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    #home-manager-stable = {
    #  url = "github:nix-community/home-manager/release-24.11";
    #  inputs.nixpkgs.follows = "nixpkgs-stable";
    #};
  };

  outputs =
    {
      self,
      ...
    }@inputs:

    let
      hosts = import ./config/hosts.nix;

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
