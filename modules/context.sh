#! /bin/bash

set_target() {
    local SUB_COMMAND="$1"
    local TARGET="$2" SVC="$3"

    case "$SUB_COMMAND" in
      show)
        show_context_help
        exit 1
        ;;
      project)
        if [[ -z "${TARGET:-}" ]]; then
            show_context_help
            exit 1
        else
            if grep -q "^CURRENT_PROJECT_NAME=" "$CONFIG_FILE"; then
                # Replace line (match key only)
                sed -i "s|^CURRENT_PROJECT_NAME=.*|CURRENT_PROJECT_NAME=\"${TARGET}\"|" "$CONFIG_FILE"
                info "Project name set: $TARGET"
                exit 1
            fi
        fi
        ;;
      set)
        if [[ -z "${TARGET:-}" || -z "${SVC:-}" ]]; then
            show_context_help
            exit 1
        else 
            if [[ -f "$CONTEXT_FILE" ]]; then
                echo "$TARGET $SVC" > "$CONTEXT_FILE"
                info "Context set: $TARGET $SVC"
            else
                err "Unable to locate $0 results dir."
            fi
        fi
        ;;
      *)
        err "Unknown command: $COMMAND"
        show_context_help
        exit 1
        ;;
    esac

}

check_context() {
     # --- Check if context is set ---
    if [[ -f "$CONTEXT_FILE" ]]; then
        read -r TARGET SVC < "$CONTEXT_FILE"
        if [[ -z "$TARGET" ]] && [[ -z "$SVC" ]]; then
            MSG=$(err "No context set. Use: $0 context <TARGET(DOMAIN/IP)> <PORT_SERVICE>")
            STATUS=1
            echo "0|0|$MSG|$STATUS"
        else
            MSG=$(info "Current context: TARGET=${TARGET} SVC=${SVC}")
            STATUS=0
            echo "$TARGET|$SVC|$MSG|$STATUS"
        fi
    else
        MSG=$(err "No context set. Use: $0 context <TARGET(DOMAIN/IP)> <PORT_SERVICE>")
        STATUS=1
        echo "0|0|$MSG|$STATUS"
    fi
}

show_context() {
    if [[ -f "$CONTEXT_FILE" ]]; then
        read -r TARGET SVC < "$CONTEXT_FILE"
        if [[ -z "$TARGET" ]] && [[ -z "$SVC" ]]; then
            err "No context set. Use: $0 context <TARGET(DOMAIN/IP)> <PORT_SERVICE>"
        else
            PROJECT=$(grep "^CURRENT_PROJECT_NAME=" "$CONFIG_FILE")
            info "Current context: TARGET=${TARGET} SVC=${SVC} ${PROJECT}"
        fi
    else
        err "No context set. Use: $0 context <TARGET(DOMAIN/IP)> <PORT_SERVICE>"
    fi
}

show_context_help() {
    err "Usage: 
        $0 context set <TARGET(IP/DOMAIN)> <PORT_SERVICE> - to set context
        $0 context show - to show current context
        $0 context project <STRING> - to set project name
        "
}