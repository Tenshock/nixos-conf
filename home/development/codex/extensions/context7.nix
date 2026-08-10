{ pkgs, ... }:
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
    env = {
      CONTEXT7_API_KEY = "op://Personal/Context7 - Codex/credential";
      PATH = "${pkgs.nodejs}/bin:${pkgs.bash}/bin";
    };
    startup_timeout_sec = 60;
  };
}
