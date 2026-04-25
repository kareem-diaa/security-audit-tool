#!/bin/bash
source "$(dirname "$0")/../config.sh"

REPORT_TXT="$REPORT_DIR/audit_report_$TIMESTAMP.txt"
REPORT_HTML="$REPORT_DIR/audit_report_$TIMESTAMP.html"

# Collect all findings from tmp files
ALL_FINDINGS=$(cat "$TMP_DIR"/*.txt 2>/dev/null)

# Count severities
HIGH=$(echo "$ALL_FINDINGS" | grep -c "\[HIGH\]")
MED=$(echo "$ALL_FINDINGS"  | grep -c "\[MED\]")
LOW=$(echo "$ALL_FINDINGS"  | grep -c "\[LOW\]")

# Risk score (HIGH=3, MED=2, LOW=1)
SCORE=$(( (HIGH * 3) + (MED * 2) + (LOW * 1) ))

if   [[ $SCORE -ge 30 ]]; then RISK_LEVEL="CRITICAL"
elif [[ $SCORE -ge 15 ]]; then RISK_LEVEL="HIGH"
elif [[ $SCORE -ge 8  ]]; then RISK_LEVEL="MEDIUM"
else                            RISK_LEVEL="LOW"
fi

# ─── Plain text report ───────────────────────────────────────────────
{
echo "============================================"
echo "   AUTOMATED SYSTEM AUDIT REPORT"
echo "   Generated: $(date)"
echo "   Host:      $(hostname)"
echo "   User:      $(whoami)"
echo "============================================"
echo ""
echo "SUMMARY"
echo "-------"
echo "  HIGH findings : $HIGH"
echo "  MED  findings : $MED"
echo "  LOW  findings : $LOW"
echo "  Risk Score    : $SCORE  ($RISK_LEVEL)"
echo ""
echo "RECOMMENDATIONS"
echo "---------------"
echo "$ALL_FINDINGS" | grep "\[HIGH\]" | while read -r line; do
    item=$(echo "$line" | sed 's/\[HIGH\] //')
    case "$item" in
        *"Unexpected open port"*)
            port=$(echo "$item" | grep -oP '\d+$')
            echo "  - Close port $port or add to AUTHORIZED_PORTS in config.sh if intentional"
            ;;
        *"SUID binary"*)
            bin=$(echo "$item" | awk '{print $NF}')
            echo "  - Review $bin: remove SUID if not required: chmod u-s $bin"
            ;;
        *"Non-root UID-0"*)
            echo "  - $item: change UID or delete account immediately"
            ;;
        *"Empty/locked password"*)
            user=$(echo "$item" | awk '{print $NF}')
            echo "  - Lock account $user: passwd -l $user"
            ;;
        *"NOPASSWD"*)
            echo "  - Remove NOPASSWD from sudoers: visudo"
            ;;
    esac
done
echo ""
echo "FULL FINDINGS"
echo "-------------"
echo "$ALL_FINDINGS"
} > "$REPORT_TXT"

echo "[*] Text report saved: $REPORT_TXT"

# ─── HTML report ─────────────────────────────────────────────────────
{
cat <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Audit Report - $(hostname)</title>
<style>
  body { font-family: monospace; background: #0d1117; color: #c9d1d9; padding: 2rem; }
  h1 { color: #58a6ff; border-bottom: 1px solid #30363d; padding-bottom: .5rem; }
  h2 { color: #8b949e; margin-top: 2rem; }
  .summary { display: flex; gap: 1rem; margin: 1rem 0; flex-wrap: wrap; }
  .card { padding: .8rem 1.5rem; border-radius: 8px; font-size: 1.1rem; font-weight: bold; }
  .card-high  { background: #3d1c1c; color: #f85149; border: 1px solid #f85149; }
  .card-med   { background: #2d2208; color: #e3b341; border: 1px solid #e3b341; }
  .card-low   { background: #122820; color: #3fb950; border: 1px solid #3fb950; }
  .card-score { background: #1c2333; color: #58a6ff; border: 1px solid #58a6ff; }
  .HIGH { color: #f85149; }
  .MED  { color: #e3b341; }
  .LOW  { color: #3fb950; }
  .findings { background: #161b22; border: 1px solid #30363d; border-radius: 6px; padding: 1rem; }
  .findings p { margin: .2rem 0; }
  .rec { background: #1c2333; border-left: 3px solid #58a6ff; padding: .5rem 1rem; margin: .4rem 0; border-radius: 0 6px 6px 0; }
  .meta { color: #8b949e; font-size: .9rem; margin-bottom: 1.5rem; }
</style>
</head>
<body>
<h1>System Audit Report</h1>
<p class="meta">Host: $(hostname) &nbsp;|&nbsp; Date: $(date) &nbsp;|&nbsp; User: $(whoami)</p>

<div class="summary">
  <div class="card card-high">HIGH: $HIGH</div>
  <div class="card card-med">MED: $MED</div>
  <div class="card card-low">LOW: $LOW</div>
  <div class="card card-score">Risk Score: $SCORE &mdash; $RISK_LEVEL</div>
</div>

<h2>Recommendations</h2>
HTML

echo "$ALL_FINDINGS" | grep "\[HIGH\]" | while read -r line; do
    item=$(echo "$line" | sed 's/\[HIGH\] //')
    rec=""
    case "$item" in
        *"Unexpected open port"*)
            port=$(echo "$item" | grep -oP '\d+$')
            rec="Close port $port or whitelist it in config.sh if intentional" ;;
        *"SUID binary"*)
            bin=$(echo "$item" | awk '{print $NF}')
            rec="Review SUID on $bin — remove if not required: <code>chmod u-s $bin</code>" ;;
        *"Non-root UID-0"*)
            rec="$item — change UID or delete account immediately" ;;
        *"Empty/locked password"*)
            user=$(echo "$item" | awk '{print $NF}')
            rec="Lock account $user: <code>passwd -l $user</code>" ;;
        *"NOPASSWD"*)
            rec="Remove NOPASSWD from sudoers: <code>visudo</code>" ;;
    esac
    [[ -n "$rec" ]] && echo "<div class='rec'>$rec</div>"
done

echo "<h2>Full Findings</h2><div class='findings'>"

echo "$ALL_FINDINGS" | while read -r line; do
    if echo "$line" | grep -q "\[HIGH\]"; then
        echo "<p class='HIGH'>$line</p>"
    elif echo "$line" | grep -q "\[MED\]"; then
        echo "<p class='MED'>$line</p>"
    elif echo "$line" | grep -q "\[LOW\]"; then
        echo "<p class='LOW'>$line</p>"
    elif [[ -n "$line" ]]; then
        echo "<p>$line</p>"
    fi
done

echo "</div></body></html>"
} > "$REPORT_HTML"

echo "[*] HTML report saved: $REPORT_HTML"