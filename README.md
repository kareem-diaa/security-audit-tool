# Automated System Audit Tool
![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Gemini API](https://img.shields.io/badge/Powered%20By-Gemini%20API-4285F4?style=for-the-badge&logo=google-gemini&logoColor=white)

**CET216 – Linux and Shell Programming | Spring 2026**

A high-performance, modular security auditing framework designed for automated vulnerability assessment of Linux-based systems. This tool facilitates deep system inspection, risk quantification, and actionable intelligence through a dual-reporting engine (HTML/Text) enhanced by Large Language Model (LLM) analysis.

---

## 🚀 Features

- **Network Surface Analysis**: Automated port scanning with white-list verification against `config.sh`.
- **Privilege & Identity Audit**: Deep inspection of user accounts, UID-0 verification, and sudoer configuration.
- **FileSystem Security**: Recursive enumeration of SUID/SGID binaries and world-writable directory/file identification.
- **Package Management**: Automated verification of system patches and upgradable package inventory.
- **AI-Powered Executive Summary**: Integrated **Gemini API** module that analyzes raw audit findings to provide high-level risk assessment and prioritized strategic recommendations.
- **Actionable Remediation**: Context-aware recommendation engine providing exact shell commands (e.g., `chmod`, `passwd`) for vulnerability mitigation.
- **Risk Scoring**: Quantitative risk assessment (LOW to CRITICAL) based on findings density and severity.

---

## 🛠 Prerequisites

Ensure the following dependencies are installed on the host system:

- **Core Utilities**: `bash` (v4.0+), `grep`, `sed`, `awk`, `find`.
- **Networking**: `nmap` (recommended) or `ss` for port discovery.
- **Data Processing**: `jq` (required for AI reporting module).
- **Network I/O**: `curl` (required for Gemini API integration).

```bash
# Installation on Debian/Ubuntu
sudo apt update && sudo apt install -y nmap jq curl
```

---

## ⚙️ Setup & Configuration

### Environment Variables
The tool uses a `.env` file for sensitive configuration (specifically API keys) to ensure they are not committed to version control.

1. Create a `.env` file in the root directory:
   ```bash
   touch .env
   ```
2. Populate the file with your Gemini API key:
   ```env
   # .env - Do not commit this file!
   Gemini_API_KEY=your_google_gemini_api_key_here
   Gemini_Model_Name=gemini-2.5-flash
   ```

### Local Configuration
Modify `config.sh` to define the security baseline for the target system:
- `AUTHORIZED_PORTS`: List of ports expected to be open (e.g., "22 80 443").
- `AUTHORIZED_USERS`: List of users permitted to have login shells.

---

## 📖 Usage Flow

### Quick Start
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/kareem-diaa/security-audit-tool.git
   cd security-audit-tool
   ```
2. **Provision Dependencies**:
   ```bash
   sudo apt install nmap jq curl
   ```
3. **Configure Environment**:
   ```bash
   echo "Gemini_API_KEY=YOUR_KEY" > .env
   ```
4. **Execute Audit**:
   ```bash
   chmod +x audit.sh
   sudo ./audit.sh
   ```

Reports are generated in the `./output/` directory with timestamps.

---

## 🏗 Architecture

The tool follows a decoupled, modular architecture for scalability and maintainability:

1. **Orchestrator (`audit.sh`)**: Manages the execution lifecycle, loads environment variables, and triggers sub-modules.
2. **Analysis Modules (`modules/*.sh`)**: Specialized scripts that execute atomic checks. Findings are serialized as plain text into `$TMP_DIR` (default: `/tmp/audit_*`).
3. **Report Aggregator (`report/report.sh`)**: Consumes the ephemeral files from `$TMP_DIR`, calculates the risk score, interfaces with the Gemini API for the executive summary, and generates final artifacts.
4. **Data Persistence**: Final reports are stored in `output/` in both `.txt` (CLI consumption) and `.html` (visual consumption) formats.

---

## 👥 Team
- **Kareem Diaa** — Networks & Cybersecurity, SUT
- **Ahmed Mohamed** — Networks & Cybersecurity, SUT
