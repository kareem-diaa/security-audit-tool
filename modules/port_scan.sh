#!/usr/bin/env bash
set -u
source "$(dirname "$0")/../config.sh"

OUTPUT="$TMP_DIR/port_findings.txt"
mkdir -p "$TMP_DIR"

echo "=== Port Scan ===" | tee "$OUTPUT"

# Get all listening ports
OPEN_PORTS=$(ss -tuln | awk 'NR>1 {print $5}' | grep -oP '(\d+\.\d+\.\d+\.\d+|::|\*):(\K\d+)' | sort -un)

if [[ -z "$OPEN_PORTS" ]]; then
    echo "$SEVERITY_LOW No open ports detected" | tee -a "$OUTPUT"
else
    while read -r port; do
        if [[ " ${AUTHORIZED_PORTS[*]} " =~ " $port " ]]; then
            echo "$SEVERITY_LOW Authorized port open: $port" | tee -a "$OUTPUT"
        else
            echo "$SEVERITY_HIGH Unexpected open port: $port" | tee -a "$OUTPUT"
        fi
    done <<< "$OPEN_PORTS"
fi

# Try nmap if available for extra detail
if command -v nmap &>/dev/null; then
    echo "" | tee -a "$OUTPUT"
    echo "--- nmap service scan ---" | tee -a "$OUTPUT"
    nmap -sV --open -p- localhost 2>/dev/null | grep "^[0-9]" | tee -a "$OUTPUT"
fi

echo "" | tee -a "$OUTPUT"