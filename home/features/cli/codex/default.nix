{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  integrations = [
    ./caveman.nix
    ./context7.nix
    ./gitnexus.nix
    ./playwright.nix
    ./serena.nix
  ];

  importIntegration =
    integration:
    let
      imported = import integration;
    in
    if lib.isFunction imported then
      imported {
        inherit
          config
          inputs
          lib
          pkgs
          ;
      }
    else
      imported;

  integrationConfigs = map importIntegration integrations;

  integrationPackages = lib.concatMap (integration: integration.packages or [ ]) integrationConfigs;

  mcpServers = lib.foldl' (
    servers: integration: servers // (integration.mcp_servers or { })
  ) { } integrationConfigs;

  skills = lib.foldl' (
    codexSkills: integration: codexSkills // (integration.skills or { })
  ) { } integrationConfigs;

  trustedProjects = [
    # Misc
    "${config.home.homeDirectory}/repo/anssi-lab-entretien-technique"

    # Personal
    "${config.home.homeDirectory}/.config/nixos"
    "${config.home.homeDirectory}/.config/nvim"
  ];

  projects = lib.genAttrs trustedProjects (_: {
    trust_level = "trusted";
  });
in
{
  home.packages = integrationPackages;

  programs.codex = {
    enable = true;
    inherit skills;
    context = ''
      Use caveman mode by default in every session.
      Keep all technical details exact.
      Stop only if user says "stop caveman" or "normal mode".
    '';
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
