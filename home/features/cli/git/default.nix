{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
    git-sizer
  ];

  programs = {
    git = {
      enable = true;

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
          condition = "gitdir:~/projects/betagouv/**";
          contents = {
            commit.gpgSign = true;
            gpg.format = "openpgp";
            user = {
              email = "cedric.prezelin.ext@beta.gouv.fr";
              signingKey = "F7685F485C283BEA";
            };
          };
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
