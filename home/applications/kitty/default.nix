{ pkgs, ... }:
let
  kittyGotoTab = pkgs.writeShellApplication {
    name = "kitty-goto-tab";
    runtimeInputs = [
      pkgs.jq
      pkgs.kitty
    ];
    text = ''
      target="''${1:?tab slot required}"

      if [[ ! "$target" =~ ^([1-9]|10)$ ]]; then
        printf 'invalid kitty tab slot: %s\n' "$target" >&2
        exit 2
      fi

      get_os_state() {
        kitten @ ls --match-tab state:focused_os_window | jq -c '.[0]'
      }

      os_state="$(get_os_state)"
      managed_count="$(printf '%s' "$os_state" | jq '
        def slot:
          (([.windows[].user_vars.kitty_tab_slot? | select(. != null and . != "")] | first)
            // (if (.title | test("^([1-9]|10)$")) then .title else null end))
          | if . == null then null else tonumber end;
        [.tabs[] | slot | select(. != null)] | length
      ')"

      if [[ "$managed_count" == 0 ]]; then
        kitten @ set-tab-title --match state:focused 1
        kitten @ set-user-vars --match state:focused kitty_tab_slot=1
        os_state="$(get_os_state)"
      fi

      read -r source_tab_id source_window_id < <(
        printf '%s' "$os_state" | jq -r '
          (.tabs[] | select(.is_focused)) as $tab
          | [$tab.id, ($tab.windows[] | select(.is_focused) | .id)]
          | @tsv
        '
      )

      read -r tab_id window_id < <(
        printf '%s' "$os_state" | jq -r --argjson target "$target" '
          def slot:
            (([.windows[].user_vars.kitty_tab_slot? | select(. != null and . != "")] | first)
              // (if (.title | test("^([1-9]|10)$")) then .title else null end))
            | if . == null then null else tonumber end;
          ([.tabs[] | select(slot == $target) | [.id, .windows[0].id]] | first // ["", ""])
          | @tsv
        '
      )

      if [[ -n "$tab_id" ]]; then
        kitten @ focus-tab --match "id:$tab_id"
        kitten @ set-user-vars --match "id:$window_id" "kitty_tab_slot=$target"
        if [[ "$source_tab_id" != "$tab_id" ]]; then
          kitten @ set-user-vars --match "id:$source_window_id" kitty_cleanup_requested=1
        fi
        exit 0
      fi

      move_count="$(
        printf '%s' "$os_state" | jq -r --argjson target "$target" '
          def slot:
            (([.windows[].user_vars.kitty_tab_slot? | select(. != null and . != "")] | first)
              // (if (.title | test("^([1-9]|10)$")) then .title else null end))
            | if . == null then null else tonumber end;
          [.tabs[] | slot | select(. != null and . > $target)] | length
        '
      )"

      launch_args=(
        --type=tab
        --cwd=current
        --tab-title "$target"
        --var "kitty_tab_slot=$target"
        --location=last
      )

      new_window_id="$(kitten @ launch "''${launch_args[@]}")"
      kitten @ focus-window --match "id:$new_window_id"

      for ((i = 0; i < move_count; i++)); do
        kitten @ action move_tab_backward
      done

      kitten @ set-user-vars --match "id:$source_window_id" kitty_cleanup_requested=1
    '';
  };

  kittyGotoTabs = pkgs.runCommand "kitty-goto-tabs" { } ''
    mkdir -p "$out/bin"

    for target in $(seq 1 10); do
      wrapper="$out/bin/kitty-goto-tab-$target"
      printf '#!%s\nexec %s %s\n' \
        '${pkgs.runtimeShell}' \
        '${kittyGotoTab}/bin/kitty-goto-tab' \
        "$target" > "$wrapper"
      chmod +x "$wrapper"
    done
  '';

  mkGotoTabMap =
    key: slot:
    "map --allow-fallback=shifted,ascii alt+${key} remote_control_script ${kittyGotoTabs}/bin/kitty-goto-tab-${toString slot}";

  # Mapping options use Kitty's shell-like tokenizer, where quote keys are
  # interpreted as string delimiters. Without options they remain key names.
  mkQuoteGotoTabMap =
    key: slot:
    "map alt+${key} remote_control_script ${kittyGotoTabs}/bin/kitty-goto-tab-${toString slot}";

  gotoTabMaps = builtins.concatStringsSep "\n" [
    (mkGotoTabMap "1" 1)
    (mkGotoTabMap "&" 1)
    (mkGotoTabMap "2" 2)
    (mkGotoTabMap "é" 2)
    (mkGotoTabMap "3" 3)
    (mkQuoteGotoTabMap "\"" 3)
    (mkGotoTabMap "4" 4)
    (mkQuoteGotoTabMap "'" 4)
    (mkGotoTabMap "5" 5)
    (mkGotoTabMap "(" 5)
    (mkGotoTabMap "6" 6)
    (mkGotoTabMap "-" 6)
    (mkGotoTabMap "7" 7)
    (mkGotoTabMap "è" 7)
    (mkGotoTabMap "8" 8)
    (mkGotoTabMap "_" 8)
    (mkGotoTabMap "9" 9)
    (mkGotoTabMap "ç" 9)
    (mkGotoTabMap "0" 10)
    (mkGotoTabMap "à" 10)
  ];
in
{
  home.packages = [ kittyGotoTabs ];
  xdg = {
    configFile = {
      "kitty/neighboring_window.py".source =
        "${pkgs.vimPlugins.smart-splits-nvim}/kitty/neighboring_window.py";
      "kitty/pristine_tabs.py".source = ./pristine_tabs.py;
      "kitty/tab_bar.py".source = ./tab_bar.py;
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 14;
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";

      # Match tmux split geometry: -h is side-by-side, -v is top-and-bottom.
      "alt+h" = "launch --cwd=current --location=vsplit";
      "alt+v" = "launch --cwd=current --location=hsplit";
      "alt+w" = "close_window";
    };

    settings = {
      enabled_layouts = "splits";
      watcher = "pristine_tabs.py";
      tab_bar_min_tabs = 1;
      tab_bar_edge = "top";
      tab_bar_margin_height = "2 0";
      tab_bar_style = "custom";
      tab_title_template = "{title} {custom}";
      active_tab_title_template = "{fmt.bold}{fmt.fg._94e2d5}{title} {custom}{fmt.fg.tab}{fmt.nobold}";
      active_tab_foreground = "#cdd6f4";
      active_tab_background = "#45475a";
      active_tab_font_style = "normal";
      inactive_tab_foreground = "#a6adc8";
      inactive_tab_background = "#313244";
      inactive_tab_font_style = "normal";
      tab_bar_background = "#0f111a";
      tab_bar_margin_color = "#0f111a";
      copy_on_select = "clipboard";
      allow_remote_control = "socket-only";
      listen_on = "unix:\${XDG_RUNTIME_DIR}/kitty-{kitty_pid}";
      hide_window_decorations = true;
      macos_option_as_alt = "left";
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      cursor_trail = 50;
      cursor_trail_start_threshold = 2;
    };

    themeFile = "Catppuccin-Mocha";
    extraConfig = ''
      background #0f111a

      # Native kitty navigation; smart-splits receives these keys inside Neovim.
      map --allow-fallback=shifted,ascii ctrl+h neighboring_window left
      map --allow-fallback=shifted,ascii ctrl+j neighboring_window down
      map --allow-fallback=shifted,ascii ctrl+k neighboring_window up
      map --allow-fallback=shifted,ascii ctrl+l neighboring_window right
      map --when-focus-on var:IS_NVIM ctrl+h
      map --when-focus-on var:IS_NVIM ctrl+j
      map --when-focus-on var:IS_NVIM ctrl+k
      map --when-focus-on var:IS_NVIM ctrl+l

      ${gotoTabMaps}
    '';
  };
}
