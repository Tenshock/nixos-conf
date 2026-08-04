{ pkgs, ... }:
{
  programs.zen-browser.profiles.default.search = {
    force = true;
    default = "ddg";
    order = [
      "google"
      "ddg"
      "wikipedia"
      "youtube"
      "nixos-packages"
      "nixos-options"
      "home-manager-options"
      "online-fix"
      "amazon"
      "npm"
    ];

    engines = {
      bing.metaData.hidden = true;
      perplexity.metaData.hidden = true;
      qwant.metaData.hidden = true;

      wikipedia = {
        name = "Wikipedia";
        urls = [
          { template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}"; }
        ];
        definedAliases = [ "w" ];
      };

      youtube = {
        name = "Youtube";
        urls = [
          { template = "https://www.youtube.com/results?search_query={searchTerms}"; }
        ];
        definedAliases = [ "y" ];
      };

      nixos-packages = {
        name = "NixOS packages";
        searchForm = "https://search.nixos.org/packages";
        urls = [
          { template = "https://search.nixos.org/packages?query={searchTerms}"; }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "np" ];
      };

      nixos-options = {
        name = "NixOS Options";
        urls = [
          { template = "https://search.nixos.org/options?query={searchTerms}"; }
        ];
        icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        definedAliases = [ "no" ];
      };

      home-manager-options = {
        name = "Home Manager - Options Search";
        searchForm = "https://home-manager-options.extranix.com/";
        urls = [
          { template = "https://home-manager-options.extranix.com/?query={searchTerms}"; }
        ];
        definedAliases = [ "h" ];
      };

      online-fix = {
        name = "Online Fix";
        urls = [
          {
            template = "https://online-fix.me/index.php?do=search&subaction=search&story={searchTerms}";
          }
        ];
        definedAliases = [ "o" ];
      };

      amazon = {
        name = "Amazon";
        urls = [
          { template = "https://www.amazon.fr/s?k={searchTerms}"; }
        ];
        definedAliases = [ "a" ];
      };

      npm = {
        name = "npm";
        urls = [
          { template = "https://www.npmjs.com/search?q={searchTerms}"; }
        ];
        definedAliases = [ "n" ];
      };
    };
  };
}
