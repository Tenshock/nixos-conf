{ lib, pkgs, ... }:
let
  thunarExtract = pkgs.writeShellApplication {
    name = "thunar-extract";
    runtimeInputs = with pkgs; [
      coreutils
      gnutar
      libnotify
      unar
      unzip
      zenity
    ];
    text = ''
      log_dir="$XDG_STATE_HOME"
      mkdir -p -- "$log_dir"
      log_file=$log_dir/thunar-extract.log
      exec >>"$log_file" 2>&1

      notify_done() {
        title=$1
        body=$2
        notify-send --app-name=Thunar "$title" "$body" || true
      }

      if [ "$#" -lt 2 ]; then
        notify_done "Extract archive failed" "No archive path received. See $log_file"
        printf '[%s] missing arguments: %s\n' "$(date -Is)" "$*"
        exit 1
      fi

      mode=$1
      shift
      printf '[%s] mode=%s archives=%s\n' "$(date -Is)" "$mode" "$*"

      strip_archive_suffix() {
        name=$1
        case "$name" in
          *.tar.gz) printf '%s\n' "''${name%.tar.gz}" ;;
          *.TAR.GZ) printf '%s\n' "''${name%.TAR.GZ}" ;;
          *.tgz) printf '%s\n' "''${name%.tgz}" ;;
          *.TGZ) printf '%s\n' "''${name%.TGZ}" ;;
          *.zip) printf '%s\n' "''${name%.zip}" ;;
          *.ZIP) printf '%s\n' "''${name%.ZIP}" ;;
          *.rar) printf '%s\n' "''${name%.rar}" ;;
          *.RAR) printf '%s\n' "''${name%.RAR}" ;;
          *) printf '%s\n' "$name" ;;
        esac
      }

      prompt_password() {
        zenity --password \
          --title="Archive password"
      }

      extract_zip() {
        archive=$1
        target=$2

        if unzip -o -- "$archive" -d "$target"; then
          return 0
        fi

        if ! password=$(prompt_password "$archive"); then
          printf 'Password prompt cancelled for: %s\n' "$archive" >&2
          return 2
        fi

        unzip -o -P "$password" -- "$archive" -d "$target"
      }

      extract_rar() {
        archive=$1
        target=$2
        unar_options=(-f)

        if [ "$mode" = "folder" ]; then
          unar_options+=(-D)
        fi

        if unar "''${unar_options[@]}" -o "$target" "$archive"; then
          return 0
        fi

        if ! password=$(prompt_password "$archive"); then
          printf 'Password prompt cancelled for: %s\n' "$archive" >&2
          return 2
        fi

        unar "''${unar_options[@]}" -p "$password" -o "$target" "$archive"
      }

      extract_target() {
        archive=$1
        archive_dir=$(dirname -- "$archive")

        if [ "$mode" = "folder" ]; then
          archive_base=$(basename -- "$archive")
          target=$archive_dir/$(strip_archive_suffix "$archive_base")
          mkdir -p -- "$target"
        else
          target=$archive_dir
        fi

        case "$archive" in
          *.zip|*.ZIP)
            extract_zip "$archive" "$target"
            ;;
          *.tar.gz|*.TAR.GZ|*.tgz|*.TGZ)
            tar -xzf "$archive" -C "$target"
            ;;
          *.rar|*.RAR)
            extract_rar "$archive" "$target"
            ;;
          *)
            printf 'Unsupported archive: %s\n' "$archive" >&2
            return 1
            ;;
        esac
      }

      canceled=0
      failed=0
      for archive in "$@"; do
        if extract_target "$archive"; then
          continue
        else
          status=$?
          if [ "$status" -eq 2 ]; then
            canceled=1
          else
            failed=1
          fi
        fi
      done

      if [ "$failed" -ne 0 ]; then
        notify_done "Extract archive failed" "See $log_file"
        exit 1
      elif [ "$canceled" -eq 0 ]; then
        notify_done "Extract archive" "Done"
      fi
      exit 0
    '';
  };

  archivePatterns = "*.rar;*.RAR;*.zip;*.ZIP;*.tar.gz;*.TAR.GZ;*.tgz;*.TGZ";
in
{
  home.packages = with pkgs; [
    unar
    unzip
    thunarExtract
  ];

  xdg.configFile."Thunar/uca.xml" = lib.mkIf pkgs.stdenv.isLinux {
    text =
      # xml
      ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
      <action>
        <icon>utilities-terminal</icon>
        <name>Open Terminal Here</name>
        <submenu></submenu>
        <unique-id>1782482197099335-1</unique-id>
        <command>exo-open --working-directory %f --launch TerminalEmulator</command>
        <description>Open a terminal in this directory</description>
        <range></range>
        <patterns>*</patterns>
        <startup-notify/>
        <directories/>
      </action>
      <action>
        <icon>package-x-generic</icon>
        <name>Extract Here</name>
        <submenu></submenu>
        <unique-id>1782820000000000-1</unique-id>
        <command>${thunarExtract}/bin/thunar-extract here %f</command>
        <description>Extract selected archives into their current folder</description>
        <range></range>
        <patterns>${archivePatterns}</patterns>
        <other-files/>
      </action>
      <action>
        <icon>folder-new</icon>
        <name>Extract to Folder</name>
        <submenu></submenu>
        <unique-id>1782820000000000-2</unique-id>
        <command>${thunarExtract}/bin/thunar-extract folder %f</command>
        <description>Extract each selected archive into a folder named after the archive</description>
        <range></range>
        <patterns>${archivePatterns}</patterns>
        <other-files/>
      </action>
      </actions>
    '';
  };
}
