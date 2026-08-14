{ pkgs, ... }:
let
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
  '';
in
{
  programs.lazyvim = {
    extraPackages = [
      codelldb
      pkgs.rust-analyzer
    ];

    extras.lang.rust.enable = true;
  };
}
