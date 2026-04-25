
# Automated System Audit Tool
**CET216 – Linux and Shell Programming | Spring 2026**

A modular bash-based security auditing tool that scans a Linux system for
common vulnerabilities and generates actionable reports.

## Features
- Open port detection with whitelist comparison
- User account and privilege analysis
- SUID/SGID binary enumeration
- World-writable file and directory detection
- Outdated package detection
- Risk scoring (LOW / MEDIUM / HIGH / CRITICAL)
- Dual output: color-coded HTML report + plain-text report

## Usage
```bash
sudo bash audit.sh
```
Reports are saved to `./output/`.

## Configuration
Edit `config.sh` to customize:
- `AUTHORIZED_PORTS` — ports considered safe
- `AUTHORIZED_USERS` — expected admin accounts
- `REPORT_DIR` — output directory

## Project Structure
audit-tool/
├── audit.sh          # Orchestrator
├── config.sh         # Settings
├── modules/
│   ├── port_scan.sh
│   ├── user_audit.sh
│   ├── file_perms.sh
│   └── pkg_audit.sh
├── report/
│   └── report.sh     # HTML + text report generator
└── output/           # Generated reports (git-ignored)

## Team
- Kareem Diaa — Networks & Cybersecurity, SUT
