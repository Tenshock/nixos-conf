{
  sources ? import ./npins,
}:
let
  hosts = import ./hosts/hosts.nix;
  host = hosts.framework-13;
  systemName = host.arch;
  dependencies = import ./dependencies.nix {
    inherit sources;
    system = systemName;
  };

  nixosConfigurations = {
    "${host.hostname}" = import "${sources.nixpkgs}/nixos/lib/eval-config.nix" {
      system = systemName;
      specialArgs = {
        inherit dependencies sources;
      };
      modules = [
        (import ./hosts/${host.dir}/configuration.nix host.user)
        ./hosts/${host.dir}/hardware-configuration.nix
        (import ./hosts/${host.dir}/networking.nix {
          hostName = host.hostname;
          inherit (host) user;
        })
        dependencies.nixosModules.nixosHardware
        dependencies.nixosModules.nvbroadcast
        dependencies.nixosModules.homeManager
        dependencies.nixosModules.catppuccin
        dependencies.nixosModules.monique
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit dependencies sources;
            };
            users."${host.user}" = {
              disabledModules = [
                # TODO: remove when https://github.com/nix-community/home-manager/pull/9785 merged
                "programs/git.nix"
                # TODO: remove when https://github.com/nix-community/home-manager/pull/9782 merged
                "services/window-managers/hyprland.nix"
              ];
              imports = [
                # TODO: remove when https://github.com/nix-community/home-manager/pull/9785 merged
                "${sources.home-manager-git}/modules/programs/git.nix"
                # TODO: remove when https://github.com/nix-community/home-manager/pull/9782 merged
                "${sources.home-manager-xdph}/modules/services/window-managers/hyprland.nix"
                (import ./hosts/${host.dir}/home.nix host.user)
                dependencies.homeModules.catppuccin
              ];
            };
          };
        }
      ];
    };
  };

  nixos = nixosConfigurations."${host.hostname}";
in
rec {
  inherit nixosConfigurations;

  system = nixos.config.system.build.toplevel;
  checks.${systemName}.nixos = system;
  formatter.${systemName} = dependencies.pkgs.nixfmt-tree;
  chatgptFetch = dependencies.chatgptFetch;
  updatePins = dependencies.pkgs.writeShellApplication {
    name = "update-rolling-pins";
    runtimeInputs = [ dependencies.pkgs.npins ];
    text = ''
      exec npins update \
        catppuccin \
        caveman \
        chatgpt-desktop-linux \
        firefox-addons \
        home-manager \
        monique \
        nixpkgs \
        nixos-hardware \
        zen-browser
    '';
  };

  shell = dependencies.pkgs.mkShellNoCC {
    packages = [
      dependencies.pkgs.npins
      formatter.${systemName}
      chatgptFetch
      updatePins
    ];
  };
}
