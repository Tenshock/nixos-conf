{ pkgs, ... }:
let
  context7Cwd = pkgs.runCommand "context7-mcp-cwd" { } ''
    mkdir -p "$out"
  '';
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
      PATH = "${pkgs.nodejs}/bin:${pkgs.bash}/bin";
    };
    startup_timeout_sec = 60;
  };
}
