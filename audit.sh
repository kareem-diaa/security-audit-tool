#!/usr/bin/env bash
set -u

# Only run on Linux
OS_NAME=$(uname -s || true)
if [[ "$OS_NAME" != "Linux" ]]; then
	echo "This audit script only runs on Linux. Detected: $OS_NAME"
	exit 2
fi

source ./config.sh

# Ensure TMP_DIR and REPORT_DIR exist
mkdir -p "$TMP_DIR" "$REPORT_DIR"

echo "[*] Audit started: $(date)"
echo "[*] Running as:    $(whoami)"
echo "[*] Hostname:      $(hostname)"
echo ""

# Run modules
bash modules/port_scan.sh
bash modules/user_audit.sh
bash modules/file_perms.sh
bash modules/pkg_audit.sh

# Generate report
bash report/report.sh

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "[*] Done. Report saved to: $REPORT_DIR/audit_report_$TIMESTAMP.txt"