{ pkgs, ... }: {
  home.packages = [
    (pkgs.writeShellScriptBin "stay-awake" ''
      exec systemd-inhibit \
        --what=idle:sleep:handle-lid-switch \
        --mode=block \
        --who=stay-awake \
        --why="Manual stay-awake command" \
        "$@"
    '')
  ];

  systemd.user.services.stay-awake = {
    Unit.Description = "Prevent automatic idle and sleep";
    Service.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle:sleep:handle-lid-switch --mode=block --who=stay-awake --why=\"Power menu Never Idle toggle\" ${pkgs.coreutils}/bin/sleep infinity";
  };
}
