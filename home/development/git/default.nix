{ lib, pkgs, ... }:
let
  # 1Password "Git Commit Signing" SSH key
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII41+k73bU3ax55hLATwqeWLFU/FTKYx+Th0CG7I65Jg";

  gitLogPager = pkgs.writeShellScript "git-log-pager" ''
    gitArguments="$(${pkgs.coreutils}/bin/tr '\0' ' ' < "/proc/$PPID/cmdline")"

    if [[ "$gitArguments" == *"--decorate=full"* ]]; then
      ${pkgs.perl}/bin/perl -pe 's{(refs/(?!heads/|remotes/|tags/)[^\s,)\e]+)}{\e[34m$1\e[m}g'
    else
      ${pkgs.perl}/bin/perl -pe 's{refs/((?!heads/|remotes/|tags/)[^\s,)\e]+)}{\e[34m$1\e[m}g'
    fi | ${pkgs.delta}/bin/delta
  '';
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "git-large-files" (builtins.readFile ./git-large-files.sh))
    git-sizer
  ];

  programs = {
    git = {
      enable = true;

      iniContent.pager.log = lib.mkForce "${gitLogPager}";

      signing = {
        allowedSigners = ''
          cedric.prezelin@gmail.com,cedric.prezelin.ext@beta.gouv.fr namespaces="git" ${signingKey}
        '';
        signByDefault = true;
        format = "ssh";
        key = signingKey;
        signer = "${pkgs._1password-gui}/bin/op-ssh-sign";
      };

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

        commit.gpgSign = true;

        color.decorate = {
          branch = "green";
          remoteBranch = "red";
          tag = "yellow";
        };

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

        log = {
          decorate = "auto";
          initialDecorationSet = "all";
        };

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

    zsh.shellAliases = {
      gl = "git log --oneline --graph";
      gla = "git log --oneline --graph --all";
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
