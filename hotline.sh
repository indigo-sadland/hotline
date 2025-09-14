#! /bin/bash

# --- Get root of the project so we can use dynamic routing when calling the script ---
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# --- Init config ---
CONFIG_FILE="$PROJECT_ROOT/config/hotline.conf"

# --- Load config and store it globaly fo all modules ---
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# --- Load utils ---
UTILS="$PROJECT_ROOT/utils/utils.sh"
[ -f "$UTILS" ] && source "$UTILS"

# --- Create output dir if not exists ---
if [[ ! -e $RESULT_DIR ]]; then
    mkdir "$RESULT_DIR"
fi

# --- Create state file if not exists --- 
if [[ ! -e $CONTEXT_FILE ]]; then
    touch "$CONTEXT_FILE"
fi

# --- Sub command handler ---
COMMAND="$1"; shift

case "$COMMAND" in
  initial)
    source "$PROJECT_ROOT/modules/initial.sh"
    initial_func "$@"
    ;;
  run)
    source "$PROJECT_ROOT/modules/run.sh"
    run_func "$@"
    ;;
  context)
    source "$PROJECT_ROOT/modules/context.sh"
    set_target "$@"
    ;;
  note)
    source "$PROJECT_ROOT/modules/note.sh"
    write_note "$@"
    ;;
  collect-notes)
    source "$PROJECT_ROOT/modules/note.sh"
    collect_notes "$@"
    ;;
  help)
    show_help
  ;;
  *)
    err "Unknown command: $COMMAND"
    echo 'Check "help" command'
    exit 1
    ;;
esac
