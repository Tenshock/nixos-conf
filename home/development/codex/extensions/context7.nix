{ config, pkgs, ... }:
let
  context7Cwd = pkgs.runCommand "context7-mcp-cwd" { } ''
    mkdir -p "$out"
  '';
  context7NpmCache = "${config.xdg.cacheHome}/context7-npm";
in
{
  mcp_servers.context7 = {
    command = "/run/wrappers/bin/op";
    args = [
      "run"
      "--"
      "${pkgs.nodejs}/bin/npx"
      "-y"
      "@upstash/context7-mcp"
    ];
    cwd = "${context7Cwd}";
    env = {
      CONTEXT7_API_KEY = "op://Personal/Context7 - Codex/credential";
      NPM_CONFIG_CACHE = context7NpmCache;
      NPM_CONFIG_UPDATE_NOTIFIER = "false";
      NPM_CONFIG_FUND = "false";
      PATH = "${pkgs.nodejs}/bin:${pkgs.bash}/bin";
    };
    startup_timeout_sec = 60;
  };
}
