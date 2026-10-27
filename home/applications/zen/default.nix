{
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (inputs.firefox-addons.overlays.default pkgs pkgs) firefox-addons;

  frenchDictionary = pkgs.linkFarm "zen-french-dictionary" [
    {
      name = "fr-FR.aff";
      path = "${pkgs.hunspellDicts.fr-any}/share/hunspell/fr-toutesvariantes.aff";
    }
    {
      name = "fr-FR.dic";
      path = "${pkgs.hunspellDicts.fr-any}/share/hunspell/fr-toutesvariantes.dic";
    }
  ];
in
{
  imports = [
    inputs.zen-browser.homeModules.twilight

    ./look-and-feel.nix
    ./search-engines.nix
    ./shortcuts.nix
  ];

  home.file."${config.home.homeDirectory}/.zen/profiles.ini".force = true;

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    configPath = "${config.home.homeDirectory}/.zen";

    profiles.default = {
      name = "Default Profile";
      path = "default";

      extensions.packages = with firefox-addons; [
        ublock-origin
        onepassword-password-manager
        visbug
      ];

      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.autoDisableScopes" = 0;
        "spellchecker.dictionary" = "fr-FR,en-US";
        "spellchecker.dictionary_path" = "${frenchDictionary}";
        "zen.welcome-screen.seen" = true;
      };
    };
  };
}
