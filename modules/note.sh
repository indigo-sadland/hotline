#! /bin/bash

write_note() {

    # --- Load context.sh to be able call the functions
    PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SUB_MODULE="${PROJECT_ROOT}/modules/context.sh"
    source "$SUB_MODULE"

    # --- Read return from the check_context function ---
    CONTEXT=$(check_context)
    IFS="|" read -r TARGET SVC MSG STATUS <<< "$CONTEXT" 
    if [[ $STATUS -eq 0 ]]; then
        true
    else
        echo "$MSG"
        exit 1

    fi

    TARGET_DIR="$CURRENT_PROJECT_DIR/$TARGET"
    TARGET_SVC_DIR="$TARGET_DIR/$SVC"

    # --- Ensure TARGET_SVC_DIR exists ---
    check_target_dir
    NOTE=$*
    NOTES_FILE="$TARGET_SVC_DIR/$NOTES"
    echo "- $NOTE" >> "$NOTES_FILE"
    info "Note saved in ${NOTES_FILE}"
}

collect_notes() {
    TARGET=$1

    if [ -z "$TARGET" ]; then
        echo "Usage: $0 <TARGET>"
        exit 1
    fi

    TARGET_DIR="$CURRENT_PROJECT_DIR/$TARGET"
    GLOBAL_NOTES_FILE="$TARGET_DIR/$NOTES"

    for service_dir in "$TARGET_DIR"/*/; do
        SERVICE=$(basename "$service_dir")
        if [[ "$SERVICE" == "_logs" ]]; then
            continue
        fi

        echo "## $SERVICE" >> "$GLOBAL_NOTES_FILE"
        echo "" >> "$GLOBAL_NOTES_FILE"

        if [ -f "$service_dir/notes.md" ]; then
            echo "**Notes:**" >> "$GLOBAL_NOTES_FILE"
            cat "$service_dir/notes.md" >> "$GLOBAL_NOTES_FILE"
            echo "" >> "$GLOBAL_NOTES_FILE"
        fi

        echo "---" >> "$GLOBAL_NOTES_FILE"
        echo "" >> "$GLOBAL_NOTES_FILE"
    done

    info "Notes combined in $GLOBAL_NOTES_FILE"
}