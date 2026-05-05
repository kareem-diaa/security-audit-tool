#!/usr/bin/env bash
set -u
source "$(dirname "$0")/../config.sh"

OUTPUT="$TMP_DIR/perms_findings.txt"
mkdir -p "$TMP_DIR"

echo "=== File Permissions ===" | tee "$OUTPUT"

# Scope: only directories that matter for security
SCAN_DIRS=("/bin" "/sbin" "/usr/bin" "/usr/sbin" "/usr/local/bin" "/etc" "/var" "/home" "/tmp" "/opt")

# SUID binaries
echo "--- SUID binaries ---" | tee -a "$OUTPUT"
find "${SCAN_DIRS[@]}" -perm -4000 -type f 2>/dev/null | while read -r f; do
    echo "$SEVERITY_HIGH SUID binary: $f" | tee -a "$OUTPUT"
done

# SGID binaries
echo "--- SGID binaries ---" | tee -a "$OUTPUT"
find "${SCAN_DIRS[@]}" -perm -2000 -type f 2>/dev/null | while read -r f; do
    echo "$SEVERITY_MED SGID binary: $f" | tee -a "$OUTPUT"
done

# World-writable files (excluding /tmp)
echo "--- World-writable files ---" | tee -a "$OUTPUT"
find /etc /var /home /opt -perm -o+w -type f 2>/dev/null | while read -r f; do
    echo "$SEVERITY_MED World-writable file: $f" | tee -a "$OUTPUT"
done

# World-writable directories (excluding /tmp)
echo "--- World-writable directories ---" | tee -a "$OUTPUT"
find /etc /var /home /opt -perm -o+w -type d \
    ! -path "/var/tmp/systemd-private-*" \
    2>/dev/null | while read -r d; do
    echo "$SEVERITY_MED World-writable directory: $d" | tee -a "$OUTPUT"
done

echo "" | tee -a "$OUTPUT"