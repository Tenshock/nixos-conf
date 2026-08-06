{ pkgs, ... }: {
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
    git-sizer
  ];

  programs = {
    git = {
      enable = true;

      ignores = [
        ".serena"
      ];

      settings = {
        user = {
          name = "Cédric Prezelin";
          email = "cedric.prezelin@gmail.com";
          # 1Password "Git Commit Signing" SSH key
          signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII41+k73bU3ax55hLATwqeWLFU/FTKYx+Th0CG7I65Jg";
        };

        advice = {
          diverging = false;
          skippedCherryPicks = false;
        };

        column.ui = "auto";

        commit.gpgSign = true;

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

        gpg = {
          format = "ssh";
          ssh.program = "${pkgs._1password-gui}/bin/op-ssh-sign";
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
            user.email = "cedric.prezelin.ext@beta.gouv.fr";
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
