{ pkgs, ... }:
{
  home.file.".local/bin/gh" = {
    executable = true;
    text =
      # bash
      ''
        export GH_TOKEN='op://Personal/github.com/NixOS PAT'
        exec /run/wrappers/bin/op run -- ${pkgs.gh}/bin/gh "$@"
      '';
  };

  programs.gh = {
    enable = true;
    hosts = {
      "github.com" = {
        user = "Tenshock";
        git_protocol = "ssh";
      };
    };
  };
}
