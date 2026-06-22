{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
    git-sizer
  ];

  programs = {
    git = {
      enable = true;

      ignores = [
        ".playwright-cli/"
        ".serena/"
      ];

      settings = {
        user = {
          name = "Cédric Prezelin";
          email = "cedric.prezelin@gmail.com";
        };

        advice = {
          diverging = false;
          skippedCherryPicks = false;
        };

        column.ui = "auto";

        core = {
          autocrlf = false;
          eol = "lf";
        };

        diff = {
          algorithm = "histogram";
          compactionHeuristic = true;
          tool = "nvimdiff";
        };

        fetch = {
          all = true;
          prune = true;
          pruneTags = true;
        };

        help.autocorrect = true;

        init.defaultBranch = "main";

        merge = {
          conflictstyle = "zdiff3";
          tool = "nvimdiff";
        };

        mergetool = {
          keepBackup = false;
          prompt = false;
        };

        pull.rebase = true;

        push = {
          autoSetupRemote = true;
          default = "current";
        };

        rebase = {
          autosquash = true;
          updaterefs = true;
        };

        tag.sort = "version:refname";
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

    delta = {
      enable = true;
      enableGitIntegration = true;

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
  };
}
