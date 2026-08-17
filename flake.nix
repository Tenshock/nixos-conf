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
    codex-nvim = {
      url = "github:kkrampis/codex.nvim";
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
    tchap-desktop = {
      url = "github:Tenshock/tchap-desktop/feat/nix-package";
      inputs.nixpkgs.follows = "nixos";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixos";
    };
    lazyvim-nix = {
      url = "github:pfassina/lazyvim-nix";
      inputs.nixpkgs.follows = "nixos";
    };
    neotest-nodejs = {
      url = "github:AkisArou/neotest-nodejs";
      flake = false;
    };
    neotest-vstest = {
      url = "github:Nsidorenco/neotest-vstest";
      flake = false;
    };
    telescope-terraform-doc-nvim = {
      url = "github:ANGkeith/telescope-terraform-doc.nvim";
      flake = false;
    };
    telescope-terraform-nvim = {
      url = "github:cappyzawa/telescope-terraform.nvim";
      flake = false;
    };
    # TODO: remove when https://github.com/nix-community/home-manager/pull/9785 merged
    home-manager-git = {
      url = "github:Tenshock/home-manager/8e09684fbb2a1121b8ce416bba791979dafff5d4";
      inputs.nixpkgs.follows = "nixos";
    };
    # TODO: remove when https://github.com/NixOS/nixpkgs/pull/538136 merged
    nixpkgs-nvbroadcast = {
      url = "github:Tenshock/nixpkgs/a996b4ad0e6d7445afb231340e3d2d6a2cbaa3b9";
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
          home-manager,
        }:
        nixos.lib.nixosSystem {
          system = host.arch;
          specialArgs = { inherit inputs; };
          modules = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.chatgpt-desktop-linux.nixosModules.default
            inputs.monique.nixosModules.default

            inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series

            (import ./hosts/${host.dir}/configuration.nix host.user)
            ./hosts/${host.dir}/hardware-configuration.nix
            (import ./hosts/${host.dir}/networking.nix {
              hostName = host.hostname;
              inherit (host) user;
            })
            # TODO: remove when https://github.com/NixOS/nixpkgs/pull/538136 merged
            {
              imports = [
                (inputs.nixpkgs-nvbroadcast.outPath + "/nixos/modules/programs/nvbroadcast.nix")
              ];

              # The imported module's manual anchor is absent from the locked
              # official NixOS redirects, so validation cannot cover this mixed revision.
              documentation.nixos.checkRedirects = false;

              programs.nvbroadcast.package = inputs.nixpkgs-nvbroadcast.legacyPackages.${host.arch}.nvbroadcast;
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users."${host.user}" = {
                  disabledModules = [
                    # TODO: remove when https://github.com/nix-community/home-manager/pull/9785 merged
                    "programs/git.nix"
                  ];
                  imports = [
                    # TODO: remove when https://github.com/nix-community/home-manager/pull/9785 merged
                    (inputs.home-manager-git.outPath + "/modules/programs/git.nix")
                    (import ./hosts/${host.dir}/home.nix host.user)
                    inputs.catppuccin.homeModules.catppuccin
                    inputs.lazyvim-nix.homeManagerModules.default
                  ];
                };
              };
            }
          ];
        };
    in
    {
      checks.x86_64-linux.nixos =
        self.nixosConfigurations."${hosts.framework-13.hostname}".config.system.build.toplevel;

      formatter.x86_64-linux = inputs.nixos.legacyPackages.x86_64-linux.nixfmt-tree;

      nixosConfigurations."${hosts.framework-13.hostname}" = mkNixOSConfiguration {
        host = hosts.framework-13;
        inherit (inputs) nixos;
        inherit (inputs) home-manager;
      };
    };
}
