#!/bin/bash
source "$(dirname "$0")/../config.sh"

OUTPUT="$TMP_DIR/user_findings.txt"
mkdir -p "$TMP_DIR"

echo "=== User Audit ===" | tee "$OUTPUT"

# UID-0 accounts other than root
while IFS=: read -r username _ uid _; do
    if [[ "$uid" -eq 0 && "$username" != "root" ]]; then
        echo "$SEVERITY_HIGH Non-root UID-0 account: $username" | tee -a "$OUTPUT"
    fi
done < /etc/passwd

# Accounts with empty passwords (requires root)
SERVICE_ACCOUNTS=("dhcpcd" "messagebus" "tcpdump" "sshd" "nobody" "daemon" \
                  "bin" "sys" "games" "man" "lp" "mail" "news" "uucp" \
                  "proxy" "www-data" "backup" "list" "irc" "gnats" "_apt" \
                  "systemd-network" "systemd-resolve" "systemd-timesync" \
                  "pollinate" "usbmux" "dnsmasq" "avahi" "colord" "geoclue")

if [[ $EUID -eq 0 ]]; then
    while IFS=: read -r username password _; do
        if [[ -z "$password" || "$password" == "!" || "$password" == "*" ]]; then
            if [[ " ${SERVICE_ACCOUNTS[*]} " =~ " $username " ]]; then
                echo "$SEVERITY_LOW Locked service account (expected): $username" | tee -a "$OUTPUT"
            else
                echo "$SEVERITY_HIGH Empty/locked password on user account: $username" | tee -a "$OUTPUT"
            fi
        fi
    done < /etc/shadow
else
    echo "$SEVERITY_LOW Skipping shadow check (not root)" | tee -a "$OUTPUT"
fi

# NOPASSWD sudo entries
if grep -r "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -v "^#" | grep -q "NOPASSWD"; then
    grep -r "NOPASSWD" /etc/sudoers /etc/sudoers.d/ 2>/dev/null | grep -v "^#" | while read -r line; do
        echo "$SEVERITY_HIGH NOPASSWD sudo entry: $line" | tee -a "$OUTPUT"
    done
else
    echo "$SEVERITY_LOW No NOPASSWD sudo entries found" | tee -a "$OUTPUT"
fi

# List all users with login shells
echo "$SEVERITY_LOW Users with login shells:" | tee -a "$OUTPUT"
grep -v "/nologin\|/false" /etc/passwd | awk -F: '{print $1}' | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"