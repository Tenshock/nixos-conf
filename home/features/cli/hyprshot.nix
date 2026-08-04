{ pkgs, config, ... }:
let
  hyprshot-xdg-open = pkgs.hyprshot.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.perl ];

    postPatch = (old.postPatch or "") + ''
        perl -0pi -e 's!notify-send "Screenshot saved" \\\n\s+"\$\{message\}" \\\n\s+-t "\$NOTIF_TIMEOUT" -i "\$\{1\}" -a Hyprshot!q~(
          local action
          action=$(
              notify-send "Screenshot saved" \
                          "''${message}" \
                          -t "$NOTIF_TIMEOUT" -i "''${1}" -a Hyprshot \
                          --action default=Open --wait
          )
          case "$action" in
              default)
                  xdg-open "$1" >/dev/null 2>&1 &
                  ;;
          esac
      ) &~!se' hyprshot
    '';

    postFixup = (old.postFixup or "") + ''
      wrapProgram "$out/bin/hyprshot" \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}
    '';
  });
in
{
  home = {
    packages = [ hyprshot-xdg-open ];

    sessionVariables = {
      XDG_PICTURES_DIR = "${config.home.homeDirectory}/pictures";
    };
  };
}
