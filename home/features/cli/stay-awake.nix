{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "stay-awake" ''
      exec systemd-inhibit \
        --what=idle:sleep \
        --who=stay-awake \
        --why="Manual stay-awake command" \
        "$@"
    '')
  ];
}
