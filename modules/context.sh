#! /bin/bash

set_target() {
    local TARGET="$1" SVC="$2"
    if [[ -z "${TARGET:-}" || -z "${SVC:-}" ]]; then
        err "Usage: $0 context <TARGET(IP/DOMAIN)> <PORT_SERVICE>"
        exit 1
    fi

    if [[ -f "$CONTEXT_FILE" ]]; then
        echo "$TARGET $SVC" > "$CONTEXT_FILE"
        info "Context set: $TARGET $SVC"
    else
        err "Unable to locate $0 results dir."
    fi
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