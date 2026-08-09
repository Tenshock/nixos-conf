{
  sources,
  system,
}:
let
  pkgs = import sources.nixpkgs { inherit system; };
  pkgsUnfree = import sources.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  catppuccinPackages = (import "${sources.catppuccin}/default.nix" { inherit pkgs; }).packages;

  catppuccinNixosModule =
    { lib, ... }:
    {
      imports = [ "${sources.catppuccin}/modules/nixos" ];
      catppuccin.sources = lib.mkDefault catppuccinPackages;
    };

  catppuccinHomeModule =
    { lib, ... }:
    {
      imports = [ "${sources.catppuccin}/modules/home-manager" ];
      catppuccin.sources = lib.mkDefault catppuccinPackages;
    };

  moniquePackage = pkgs.callPackage "${sources.monique}/nix/package.nix" { };
  moniqueNixosModule =
    { lib, ... }:
    {
      imports = [ "${sources.monique}/nix/nixos-module.nix" ];
      programs.monique.package = lib.mkDefault moniquePackage;
    };

  chatgptUpdater = pkgsUnfree.callPackage "${sources.chatgpt-desktop-linux}/nix/updater.nix" { };
  chatgptFetch = pkgsUnfree.writeShellApplication {
    name = "fetch-chatgpt-source";
    runtimeInputs = [ chatgptUpdater ];
    text = ''
      exec update-chatgpt-source --source-dir ${sources.chatgpt-desktop-linux}/nix "$@"
    '';
  };
  chatgptPackage = pkgsUnfree.callPackage "${sources.chatgpt-desktop-linux}/nix" {
    requireFile =
      args:
      pkgsUnfree.requireFile (
        args
        // {
          message = ''
            ChatGPT Desktop is not redistributable. Fetch and verify the
            official Microsoft Store MSIX locally with:

              cd ~/.config/nixos
              nix-shell --run fetch-chatgpt-source
          '';
        }
      );
  };
  chatgptSelf.packages.${system}.default = chatgptPackage;
  chatgptNixosModule = import "${sources.chatgpt-desktop-linux}/nix/nixos-module.nix" {
    self = chatgptSelf;
  };

  zenPackages = import sources.zen-browser { inherit pkgs; };
  zenSelf = {
    outPath = sources.zen-browser.outPath;
    packages.${system} = zenPackages;
  };
  zenTwilightHomeModule = import "${sources.zen-browser}/hm-module" {
    self = zenSelf;
    home-manager = {
      outPath = sources.home-manager.outPath;
    };
    name = "twilight";
  };

  nvbroadcastPackages = import sources.nvbroadcast-nixpkgs { inherit system; };
  nvbroadcastNixosModule = {
    imports = [ "${sources.nvbroadcast-nixpkgs}/nixos/modules/programs/nvbroadcast.nix" ];

    # The imported module's manual anchor is absent from the locked official
    # NixOS redirects, so validation cannot cover this mixed revision.
    documentation.nixos.checkRedirects = false;

    programs.nvbroadcast.package = nvbroadcastPackages.nvbroadcast;
  };
in
{
  inherit chatgptFetch pkgs;

  mkFirefoxAddons =
    firefoxPkgs:
    let
      libMozilla = import "${sources.firefox-addons}/lib/mozilla.nix" {
        lib = firefoxPkgs.lib;
      };
    in
    firefoxPkgs.callPackage "${sources.firefox-addons}/pkgs/firefox-addons" {
      buildMozillaXpiAddon = libMozilla.mkBuildMozillaXpiAddon {
        inherit (firefoxPkgs) fetchurl stdenv;
      };
    };

  nixosModules = {
    catppuccin = catppuccinNixosModule;
    chatgptDesktop = chatgptNixosModule;
    homeManager = "${sources.home-manager}/nixos";
    monique = moniqueNixosModule;
    nixosHardware = "${sources.nixos-hardware}/framework/13-inch/amd-ai-300-series";
    nvbroadcast = nvbroadcastNixosModule;
  };

  homeModules = {
    catppuccin = catppuccinHomeModule;
    zenTwilight = zenTwilightHomeModule;
  };

  packages = {
    chatgptDesktop = chatgptPackage;
    monique = moniquePackage;
    nvbroadcast = nvbroadcastPackages.nvbroadcast;
    zenTwilight = zenPackages.twilight;
  };
}
