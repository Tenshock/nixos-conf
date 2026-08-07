{
  description = "Nix Dotsfiles with flake";

  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixos";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixos";
    };
    caveman = {
      url = "github:JuliusBrussee/caveman";
      flake = false;
    };
    monique = {
      url = "github:ToRvaLDz/monique";
      inputs.nixpkgs.follows = "nixos";
    };

    chatgpt-desktop-linux = {
      url = "github:Tenshock/chatgpt-desktop-linux";
      inputs.nixpkgs.follows = "nixos";
    };

    home-manager = {
      url = "github:Tenshock/home-manager/f0d9d6468869bad5088aabe86f8c0b4a16411c6b";
      inputs.nixpkgs.follows = "nixos";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixos";
        home-manager.follows = "home-manager";
      };
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixos";
    };
  };

  outputs =
    { self, ... }@inputs:

    let
      hosts = import ./hosts/hosts.nix;

      mkNixOSConfiguration =
        {
          host,
          nixos,
          nixos-hardware,
          home-manager,
          catppuccin,
          monique,
        }:
        nixos.lib.nixosSystem {
          system = host.arch;
          specialArgs = { inherit inputs; };
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
            monique.nixosModules.default
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
    in
    {
      nixosConfigurations."${hosts.framework-13.hostname}" = mkNixOSConfiguration {
        host = hosts.framework-13;
        inherit (inputs) nixos;
        inherit (inputs) nixos-hardware;
        inherit (inputs) home-manager;
        inherit (inputs) catppuccin;
        inherit (inputs) monique;
      };
    };
}
