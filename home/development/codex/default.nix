{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  integrations = [
    ./extensions/caveman.nix
    ./extensions/context7.nix
    ./extensions/openai-docs.nix
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

  trustedProjectDirectories = [
    "${config.home.homeDirectory}/projects/betagouv"
    "${config.home.homeDirectory}/projects/own"
  ];

  trustedOwnedProjects =
    directory:
    let
      entries = builtins.readDir directory;
      directories = lib.attrNames (lib.filterAttrs (_: type: type == "directory") entries);
    in
    map (project: "${directory}/${project}") directories;

  trustedProjects = (lib.concatMap trustedOwnedProjects trustedProjectDirectories) ++ [
    # Personal
    "${config.home.homeDirectory}/.config/nixos"
    "${config.home.homeDirectory}/.config/nvim"
  ];

  projects = lib.genAttrs trustedProjects (_: {
    trust_level = "trusted";
  });
in
{
  imports = [
    ./rules.nix
  ];

  home.packages = integrationPackages ++ [
    pkgs.rtk
  ];

  programs.zsh.shellAliases.c = "codex";

  programs.codex = {
    enable = true;
    inherit skills;
    context = ''
      Use caveman skill in full mode by default in every session.
      Keep all technical details exact.
      For OpenAI products, use OpenAI Developer Docs MCP server.
      For other current library, framework, SDK, API, CLI, or cloud-service documentation, use Context7 MCP server.
      For supported shell commands, use RTK CLI when raw output would otherwise be large.
      Use raw shell commands when exact unfiltered output is needed or RTK CLI does not support command.
      Never push to remote. If not asked and justified in work, ask before creating/updating commits.
    '';
    settings = {
      model = "gpt-5.6-sol";
      model_reasoning_effort = "medium";
      review_model = "gpt-5.6-sol";
      model_provider = "openai";
      approval_policy = "on-request";
      approvals_reviewer = "auto_review";
      default_permissions = "workspace-lix";
      permissions."workspace-lix" = {
        description = "Workspace access with Lix daemon connectivity.";
        extends = ":workspace";
        network = {
          enabled = true;
          unix_sockets."/nix/var/nix/daemon-socket/socket" = "allow";
        };
      };
      tui = {
        status_line = [
          "model-with-reasoning"
          "run-state"
          "git-branch"
          "branch-changes"
          "task-progress"
          "context-remaining"
          "weekly-limit"
        ];
        vim_mode_default = true;
      };

      model_verbosity = "low";
      personality = "pragmatic";
      plan_mode_reasoning_effort = "xhigh";

      features = {
        memories = true;
        js_repl = true;
      };

      mcp_servers = mcpServers;

      plugins = {
        "build-web-apps@openai-curated".enabled = true;
        "codex-security@openai-curated".enabled = true;
        "figma@openai-curated".enabled = true;
        "github@openai-curated".enabled = true;
        "linear@openai-curated".enabled = true;
      };

      inherit projects;
    };
  };
}
