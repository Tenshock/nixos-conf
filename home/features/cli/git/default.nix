{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
  ];

  programs.git = {
    enable = true;
    userName = "Cédric Prezelin";
    userEmail = "ext-cedric.prezelin@showroomprive.net";

    extraConfig = {
      advice = {
        diverging = false;
        skippedCherryPicks = false;
      };

      core = {
        autocrlf = false;
        eol = "lf";
      };

      fetch.prune = true;

      init.defaultBranch = "main";

      merge.tool = "nvimdiff";

      pull.rebase = true;

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      rebase.autosquash = true;
    };

    includes = [
      {
        condition = "hasconfig:remote.*.url:git@github.com:Tenshock/**";
        contents.user.email = "cedric.prezelin@gmail.com";
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:seygroup/**";
        contents.user.email = "cedric.prezelin@gmail.com";
      }
    ];
  };
}
