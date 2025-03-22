{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
  ];

  programs.git = {
    enable = true;
    userName = "Cédric Prezelin";
    userEmail = "ext-cedric.prezelin@showroomprive.net";
    delta = {
      enable = true;
      options = {
        features = "decorations";
        line-numbers = true;
        navigate = true;
        decorations = {
          file-style = "omit";

          grep-output-type = "ripgrep";

          hunk-label = "🦆";
          hunk-header-style = "yellow file line-number";
          hunk-header-file-style = "bold yellow ul";
          hunk-header-line-number-style = "bold yellow ul";
          hunk-header-decoration-style = "bold yellow";

          merge-conflict-begin-symbol = ">";
          merge-conflict-end-symbol = "<";
          merge-conflict-ours-diff-header-decoration-style = "omit";
          merge-conflict-ours-diff-header-style = "yellow ul";
          merge-conflict-theirs-diff-header-decoration-style = "omit";
          merge-conflict-theirs-diff-header-style = "yellow ul";
        };
      };
    };

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

      merge = {
        conflictstyle = "zdiff3";
        tool = "nvimdiff";
      };

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
