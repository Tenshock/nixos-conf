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
      palette = "mocha";
      palettes = {
        mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };
      };
    };
  };
}
