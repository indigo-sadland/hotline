#! /bin/bash

initial_func() {

    TARGET="$1"
    NMAP_OPTS="$2"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    if [ -z "$TARGET" ] || [ -z "$NMAP_OPTS" ]; then
        echo "Usage: $0 <target> \"<nmap options>\""
        exit 1
    fi

    # Nmap grepable output file name
    GREP_OUT="/tmp/nmap_${TIMESTAMP}.gnmap"

    warn " Running nmap on $TARGET..."
    nmap $NMAP_OPTS -oG "$GREP_OUT" "$TARGET" 

    info "Nmap results saved."

    # Extract open ports and service names
    grep "Ports:" "$GREP_OUT" | while read -r line; do
        IP=$(echo "$line" | awk '{print $2}')
        PORTS=()
        SERVICES=()

        while IFS= read -r entry; do
            PORT=$(echo "$entry" | cut -d/ -f1)
            SERVICE=$(echo "$entry" | cut -d/ -f5)
            PORTS+=("$PORT")
            SERVICES+=("$SERVICE")
        done < <(echo "$line" | grep -oP '\d+/open/tcp//[^/]+' )

        HOST_DIR="${CURRENT_PROJECT_DIR}/${IP}"
        NMAP_LOG_DIR="$HOST_DIR/$SCANS_LOG_DIR/nmap/"
        mkdir -p "$NMAP_LOG_DIR"

        cp "$GREP_OUT" "$NMAP_LOG_DIR"

        # Ceate port dirs (like 22_ssh, 80_http and so on)
        for i in "${!PORTS[@]}"; do
            PORT="${PORTS[$i]}"
            SERVICE="${SERVICES[$i]}"
            DIR_NAME="${PORT}_${SERVICE}"
            mkdir -p "$HOST_DIR/$DIR_NAME"
        done

        # Save summary
        {
            echo "IP: $IP"
            echo "Open ports: ${PORTS[*]}"
            echo "Services: ${SERVICES[*]}"
        } > "$NMAP_LOG_DIR/nmap_summary.txt"

  done

}