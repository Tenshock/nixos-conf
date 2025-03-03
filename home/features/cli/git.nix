{ ... }: {
  programs.git = {
    enable = true;
    userName = "Cédric Prezelin";
    userEmail = "ext-cedric.prezelin@showroomprive.net";

    extraConfig = {
      pull.rebase = true;
      core.editor = "/run/current-system/sw/bin/nvim";

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
        contents = {
          user = {
            email = "cedric.prezelin@gmail.com";
          };
        };
      }
      {
        condition = "hasconfig:remote.*.url:git@github.com:seygroup/**";
        contents = {
          user = {
            email = "cedric.prezelin@gmail.com";
          };
        };
      }
    ];
  };
}
