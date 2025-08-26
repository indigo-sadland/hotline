#! /bin/bash

info()  { echo -e "\033[1;32m[+]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[!]\033[0m $*"; }
err()   { echo -e "\033[1;31m[-]\033[0m $*"; }

save_history() {
  local TARGET_DIR="$1" HIST="$2"
  printf "%s\n"  "$HIST" >> "${TARGET_DIR}/${CMD_HISTORY}"
}

check_target_dir() {
        if [[ -d "$TARGET_SVC_DIR" ]]; then
        true
    else
        warn "Unable to locate target dir. Is the context set correctly?"
        read -p "Create the specified dir? (Y/N): " CONFIRM
        if [[ $CONFIRM =~ ^[Yy]$ ]]; then
            mkdir -p "$TARGET_SVC_DIR"
        else
            exit 1
        fi
    fi
}

show_help() {
    cat << 'EOF'

Hotline automates logging, scanning, and note-taking during penetration testing.

Available Commands:

  initial <target|range> <nmap-args>
      Perform initial Nmap scan and set up directory structure. You want to run the command in FIRST place.
      Example:
          hotline.sh initial 10.10.10.0/24 "-sV -p-"

  context project <STRING>
      Set current project name
      Example:
          hotline.sh project hackerone
  context set <TARGET> <PORT_SERVICE>
      Set current working context for 'run' and 'note'.
      Example:
          hotline.sh context 10.10.10.5 80_http
  context show
      Show current context

  run "<TOOL COMMAND>"
      Run any tool (e.g. ffuf, feroxbuster, curl) under current context and log output.
      Example:
          hotline.sh run "ffuf -u http://10.10.10.5/FUZZ -w wordlist.txt"

  note "<your note text>"
      Add a note for current context.
      Example:
          hotline.sh note "Found potential IDOR at /user/1234"

  collect-notes <TARGET>
      Collect all notes from a given target into a single file.
      Example:
          hotline.sh collect-notes 10.10.10.5

EOF
}