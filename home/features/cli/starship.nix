{ lib, ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "[╭─](bold white)"
        "$nix_shell"
        "$username"
        "$sudo"
        "$directory"
        "$git_branch"
        "$git_commit"
        "$git_status"
        "$git_state"
        "$line_break"
        "$character"
      ];
      right_format = lib.concatStrings [ "$cmd_duration" ];
      character = {
        success_symbol = "[╰λ](bold white)";
        error_symbol = "[╰λ](bold white)";
      };
      cmd_duration = {
        format = "[$duration]($style)";
        style = "peach";
      };
      directory = {
        format = " [$path]($style)[$read_only]($read_only_style) ";
        repo_root_format =
          " [$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 10;
        truncate_to_repo = false;
        style = "bold blue";
        before_repo_root_style = "bold blue dimmed";
        repo_root_style = "bold blue";
      };
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        only_attached = true;
        style = "bold yellow";
        symbol = "";
      };
      git_commit = {
        tag_disabled = false;
        format = "[$hash$tag]($style) ";
        style = "bold yellow";
        tag_symbol = " 🏷 ";
      };
      git_state = {
        style = "bold red";
        format = "[$state( $progress_current/$progress_total)]($style) ";
      };
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold mauve dimmed";
        stashed = "";
      };
      nix_shell = {
        format = "[$symbol$state( ($name))]($style) ";
        symbol = "  ";
      };
      sudo = {
        format = "[$symbol]($style)";
        symbol = "*";
        style = "bold red";
        disabled = false;
      };
      username = {
        show_always = true;
        format = "[$user]($style)";
        style_user = "bold green";
      };
    };
  };
}
