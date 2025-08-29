#! /bin/bash

run_func() {
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    # --- Load context.sh to be able call the functions
    PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SUB_MODULE="${PROJECT_ROOT}/modules/context.sh"
    source "$SUB_MODULE"

    # --- Read return from the check_context function ---
    CONTEXT=$(check_context)
    IFS="|" read -r TARGET SVC MSG STATUS <<< "$CONTEXT" 
    if [[ $STATUS -eq 0 ]]; then
        echo "$MSG"
    else
        echo "$MSG"
        exit 1

    fi

    TARGET_DIR="$CURRENT_PROJECT_DIR/$TARGET"
    TARGET_SVC_DIR="$TARGET_DIR/$SVC"

    # --- Ensure TARGET_SVC_DIR exists ---
    check_target_dir

    # --- Check that command is passed ---
    CMD_STRING="$*" # for logs
    CMD=("$@")
    if [[ $# -eq 0 ]]; then
        err "Usage: $0 run <TOOL COMMAND>. For example: python3 ./sqlmap.py -r request --random-agent"
        exit 1
    fi

    # --- Normalize tool name for cases when python command required. For example, python3 ./sqlmap.py ----
    TOOL="${CMD[0]}"
    if [[ $1 == "python3"  ]] || [[ $1 == "python" ]]; then
        TOOL="${CMD_ARRAY[1]}"
    fi
    
    TOOL=$(basename "$TOOL")

    local PIPE_CMD
    # --- For ffuf and feroxbuster we want to use their json output flags for future tree creation proccess ---
    case $TOOL in
     ffuf)
        OUTFILE="${TARGET_SVC_DIR}/${TOOL}_${TIMESTAMP}.json"
        CMD+=(-o "$OUTFILE")
     ;;
     feroxbuster)
	OUTFILE="${TARGET_SVC_DIR}/${TOOL}_${TIMESTAMP}.json"
        CMD+=(--json -o "$OUTFILE")
     ;;
     *)
        PIPE_CMD=" | tee "${TARGET_SVC_DIR}/${TOOL}_${TIMESTAMP}.log""
    esac

    # --- Execute the given command ---
    set +e
        bash -c 'exec "$@"' _ "${CMD[@]}" "$PIPE_CMD"
        local STATUS=$?
    set -e

    # --- Save the command to history file
    local HIST
    if [[ $STATUS -eq 0 ]]; then
        HIST="- Done: $CMD_STRING"
    else
        HIST="- Err OR Interrupted: $CMD_STRING"    
    fi
    save_history "$TARGET_DIR" "$HIST"

}
