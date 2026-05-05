#!/usr/bin/env bash
set -u
source "$(dirname "$0")/../config.sh"

OUTPUT="$TMP_DIR/pkg_findings.txt"
mkdir -p "$TMP_DIR"

echo "=== Package Audit ===" | tee "$OUTPUT"

if command -v apt &>/dev/null; then
    echo "--- Checking for upgradable packages ---" | tee -a "$OUTPUT"

    UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing")

    if [[ -z "$UPGRADABLE" ]]; then
        echo "$SEVERITY_LOW All packages are up to date" | tee -a "$OUTPUT"
    else
        while read -r pkg; do
            if echo "$pkg" | grep -qi "security"; then
                echo "$SEVERITY_HIGH Security update available: $pkg" | tee -a "$OUTPUT"
            else
                echo "$SEVERITY_MED Package update available: $pkg" | tee -a "$OUTPUT"
            fi
        done <<< "$UPGRADABLE"
    fi

else
    echo "$SEVERITY_LOW apt not found — skipping package audit" | tee -a "$OUTPUT"
fi

echo "" | tee -a "$OUTPUT"