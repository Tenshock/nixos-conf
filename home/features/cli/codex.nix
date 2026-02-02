{ config, lib, ... }:
let
  trustedProjects = [
    # Seekube
    "${config.home.homeDirectory}/repo/seekube/amibuilder"
    "${config.home.homeDirectory}/repo/seekube/api"
    "${config.home.homeDirectory}/repo/seekube/chore"
    "${config.home.homeDirectory}/repo/seekube/cookie-consent"
    "${config.home.homeDirectory}/repo/seekube/data-aggregator"
    "${config.home.homeDirectory}/repo/seekube/front"
    "${config.home.homeDirectory}/repo/seekube/go-api"
    "${config.home.homeDirectory}/repo/seekube/infra"
    "${config.home.homeDirectory}/repo/seekube/jack"
    "${config.home.homeDirectory}/repo/seekube/redash-related-scripts"
    "${config.home.homeDirectory}/repo/seekube/staging"
    "${config.home.homeDirectory}/repo/seekube/ui"
    "${config.home.homeDirectory}/repo/seekube/ui-kit"

    # nvim
    "${config.home.homeDirectory}/.config/nvim"
  ];

  projects = lib.genAttrs trustedProjects (_: { trust_level = "trusted"; });
in {
  programs.codex = {
    enable = true;
    settings = {
      model = "gpt-5.2-codex";
      review_model = "gpt-5.2-codex";
      model_provider = "openai";
      inherit projects;
    };
  };
}
