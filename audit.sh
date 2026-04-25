#!/bin/bash
source ./config.sh
export TMP_DIR TIMESTAMP REPORT_DIR
export SEVERITY_HIGH SEVERITY_MED SEVERITY_LOW
export AUTHORIZED_PORTS AUTHORIZED_USERS

mkdir -p "$TMP_DIR" "$REPORT_DIR"

echo "[*] Audit started: $(date)"
echo "[*] Running as:    $(whoami)"
echo "[*] Hostname:      $(hostname)"
echo ""

bash modules/port_scan.sh
bash modules/user_audit.sh
bash modules/file_perms.sh
bash modules/pkg_audit.sh

bash report/report.sh

rm -rf "$TMP_DIR"

echo ""
echo "[*] Done. Report saved to: $REPORT_DIR/audit_report_$TIMESTAMP.txt"