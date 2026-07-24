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

  systemd.user.services.stay-awake = {
    Unit.Description = "Prevent automatic idle";
    Service.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=idle --who=stay-awake --why=\"Power menu Never Idle toggle\" ${pkgs.coreutils}/bin/sleep infinity";
  };
}
