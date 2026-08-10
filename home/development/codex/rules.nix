{ config, lib, ... }:
{
  programs.codex.rules.default = ''
    prefix_rule(
      pattern = ["rg"],
      decision = "allow",
      justification = "Allow read-only repository searches",
    )

    prefix_rule(
      pattern = ["git", "status"],
      decision = "allow",
      justification = "Allow read-only worktree status checks",
    )

    prefix_rule(
      pattern = ["git", "diff"],
      decision = "allow",
      justification = "Allow read-only worktree diff checks",
    )

    prefix_rule(
      pattern = ["nix", "eval"],
      decision = "allow",
      justification = "Allow declarative Nix evaluation",
    )

    prefix_rule(
      pattern = ["nix", "build"],
      decision = "allow",
      justification = "Allow declarative Nix builds",
    )

    prefix_rule(
      pattern = ["nh", "os", "switch"],
      decision = "prompt",
      justification = "Require confirmation before activating a NixOS configuration",
    )

    prefix_rule(
      pattern = ["nixos-rebuild", "switch"],
      decision = "prompt",
      justification = "Require confirmation before activating a NixOS configuration",
    )

    prefix_rule(
      pattern = ["home-manager", "switch"],
      decision = "prompt",
      justification = "Require confirmation before activating a Home Manager configuration",
    )
  '';

  # Replace Codex's accumulated interactive approval file with curated rules.
  home.file."${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/codex/rules/default.rules".force =
    true;
}
