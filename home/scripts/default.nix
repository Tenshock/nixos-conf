{ pkgs, ... }: {
  home.packages = with pkgs; [
    # TODO: add to git directly
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
    (writeShellScriptBin "lock-and-suspend" (builtins.readFile ./lock-and-suspend.sh))
    (writeShellScriptBin "wofi-launcher" (builtins.readFile ./wofi-launcher.sh))
    (writeShellScriptBin "wofi-power-menu" (builtins.readFile ./wofi-power-menu.sh))
  ];
}
