{ pkgs, ... }:
let
  onePasswordSignin = pkgs.writeShellApplication {
    name = "onepassword-signin";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      for _ in {1..40}; do
        if /run/wrappers/bin/op signin; then
          exit 0
        fi

        sleep 0.25
      done

      exit 1
    '';
  };
in
{
  systemd.user.services = {
    onepassword = {
      Unit = {
        Description = "1Password";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
        Restart = "on-failure";
        RestartSec = 1;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    onepassword-signin = {
      Unit = {
        Description = "Sign in to 1Password CLI";
        After = [
          "graphical-session.target"
          "onepassword.service"
        ];
        Requires = [ "onepassword.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${onePasswordSignin}/bin/onepassword-signin";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
