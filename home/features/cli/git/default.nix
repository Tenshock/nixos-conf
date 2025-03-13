{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
  ];

  programs.git = {
    enable = true;
    userName = "Cédric Prezelin";
    userEmail = "ext-cedric.prezelin@showroomprive.net";

    extraConfig = {
      core = {
        autocrlf = false;
        eol = "lf";
      };

      pull.rebase = true;

      rebase.autosquash = true;

      fetch.prune = true;

      push = {
        autoSetupRemote = true;
        default = "current";
      };

      init.defaultBranch = "main";

      advice.skippedCherryPicks = false;
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
