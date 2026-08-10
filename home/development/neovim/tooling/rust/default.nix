{ pkgs, ... }:
let
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    exec ${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
  '';
in
{
  programs.neovim.extraPackages = [
    codelldb
    pkgs.rust-analyzer
  ];

  xdg.configFile."nvim/lua/tooling-extras/rust.lua".source = ./extras.lua;
}
