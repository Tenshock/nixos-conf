{ pkgs, ... }:
{
  packages = [ pkgs.uv ];

  mcp_servers.serena = {
    startup_timeout_sec = 15;
    command = "${pkgs.uv}/bin/uvx";
    args = [
      "--from"
      "git+https://github.com/oraios/serena"
      "serena"
      "start-mcp-server"
      "--project-from-cwd"
      "--context=codex"
      "--open-web-dashboard"
      "false"
    ];
  };
}
