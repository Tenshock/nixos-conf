{ config, lib, pkgs, ... }:
let
  integrations = [
    ./context7.nix
    ./gitnexus.nix
    ./playwright.nix
    ./serena.nix
  ];

  importIntegration = integration:
    let
      imported = import integration;
    in
      if lib.isFunction imported then
        imported { inherit config lib pkgs; }
      else
        imported;

  integrationConfigs =
    map importIntegration integrations;

  integrationPackages =
    lib.concatMap (integration: integration.packages or [ ]) integrationConfigs;

  mcpServers =
    lib.foldl' (servers: integration: servers // (integration.mcp_servers or { })) { } integrationConfigs;

  skills =
    lib.foldl' (codexSkills: integration: codexSkills // (integration.skills or { })) { } integrationConfigs;

  trustedProjects = [
    # Seekube
    "${config.home.homeDirectory}/repo/seekube/amibuilder"
    "${config.home.homeDirectory}/repo/seekube/backend"
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

    # Unyka
    "${config.home.homeDirectory}/repo/unyka"

    # Personal
    "${config.home.homeDirectory}/.config/nixos"
    "${config.home.homeDirectory}/.config/nvim"
  ];

  projects = lib.genAttrs trustedProjects (_: { trust_level = "trusted"; });
in {
  home.packages = integrationPackages;

  programs.codex = {
    enable = true;
    skills = skills;
    settings = {
      model = "gpt-5.5";
      review_model = "gpt-5.5";
      model_provider = "openai";

      features = {
        memories = true;
        js_repl = true;
      };

      mcp_servers = mcpServers;

      inherit projects;
    };
  };
}
