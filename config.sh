#!/usr/bin/env bash
# config defaults for audit

# Load .env (optional) to allow setting Gemini keys etc.
if [[ -f .env ]]; then
	# shellcheck disable=SC1091
	set -a
	# shellcheck disable=SC1090
	source .env
	set +a
fi

REPORT_DIR="${REPORT_DIR:-./output}"
TIMESTAMP="${TIMESTAMP:-$(date +"%Y%m%d_%H%M%S")}"
TMP_DIR="${TMP_DIR:-/tmp/audit_$$}"

AUTHORIZED_PORTS=(22 80 443)
AUTHORIZED_USERS=("root")

SEVERITY_HIGH="[HIGH]"
SEVERITY_MED="[MED]"
SEVERITY_LOW="[LOW]"

# Export commonly-used vars
export REPORT_DIR TIMESTAMP TMP_DIR
export AUTHORIZED_PORTS AUTHORIZED_USERS
export SEVERITY_HIGH SEVERITY_MED SEVERITY_LOW