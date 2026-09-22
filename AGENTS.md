# RainbowScripts Suite Overview

> **🤖 AGENT INSTRUCTIONS:**
> As an AI Agent interacting with this repository, you **MUST PROACTIVELY** keep this `AGENTS.md` document updated. Whenever you create a new script, remove an existing one, alter core architectural patterns, or change program behaviors, you must immediately update this file to reflect the current state of the codebase and usage patterns.

This document provides a quick overview of the scripts included in the RainbowScripts suite, describing their scope and identifying common patterns across the codebase.

## Scope of the Scripts

| Script | Language | Description |
|---|---|---|
| `rainbow-backupnas` | Bash | Performs automated backups to an rsync server (NAS) using SSH keys and an include list. |
| `rainbow-checkhosts` | Bash | Checks the availability of a list of hosts via `ping` and sends a Telegram notification if any host is unreachable. |
| `rainbow-monitoragent.py` | Python 3 | Runs a simple HTTP server (port 23123) that exposes core machine metrics (CPU temperature, RAM, and Disk usage) in JSON format. |
| `rainbow-notifytelegram` | Bash | Sends text notifications to a specified Telegram chat using a Telegram Bot API token. |
| `rainbow-sshloginnotify` | Bash | PAM-triggered script that sends a Telegram notification upon a new SSH login, enriching it with geographic IP information using `ipinfo.io`. |
| `rainbow-updater` | Bash | Downloads the latest version of the RainbowScripts repository from GitHub and triggers the core updater. |
| `rainbow-upgradesystem` | Bash | Upgrades system packages automatically. It supports Alpine (`apk`) and Debian-based (`apt`/`aptitude`) distributions and notifies about the status via Telegram/Admin integrations. |
| `updater-core` | Bash | The core installation and update mechanism. It copies scripts to `/usr/local/bin`, installs cron jobs, configures services (OpenRC or Systemd), and sets up default configurations in `/etc/rainbowscripts`. |

## Common Elements and Design Patterns

Across the Bash scripts, several common architectural elements and design patterns are utilized:

1. **Root Execution Enforcement:** Most scripts include a `check_for_root` function that verifies if the script is running with EUID 0, exiting with an error if not.
2. **Standardized Output:** A common `output_message` function is used for logging and printing status messages to the console.
3. **External Configuration:** Hardcoded values are avoided. Scripts source configuration files typically located in `/etc/rainbowscripts/` (e.g., `backupnas.conf`, `notifytelegram.conf`, etc.), allowing for user-specific settings.
4. **Cross-Distribution Support:** Several scripts (like `updater-core` and `rainbow-upgradesystem`) check `/etc/os-release` to adapt their behavior for both Debian-like (Systemd, Apt) and Alpine-like (OpenRC, Apk) Linux distributions.
5. **Heavy Reliance on Notifications:** The ecosystem is heavily integrated with alerting mechanisms. Critical actions, warnings, or failures (like backups, system upgrades, or SSH logins) trigger notifications through the standalone `rainbow-notifytelegram` script.

## Coding Conventions and Rules

When creating or updating scripts in this repository, agents and contributors MUST adhere to the following rules to ensure security, reliability, and consistency:

### Bash Scripts
1. **Strict Mode:** Always include `set -euo pipefail` at the top of the script to ensure it fails fast on errors or unbound variables.
2. **Variable Quoting:** Always wrap variables in double quotes (e.g., `"$variable"`) to prevent word-splitting and unintentional globbing.
3. **Dependency Checks:** Check for the existence of external commands (using `if ! hash command_name 2>/dev/null; then`) before relying on them, and exit gracefully if they are missing.
4. **Temporary File Cleanup:** Use the `trap` statement (e.g., `trap 'rm -f "$tmp_file"' EXIT`) immediately after creating temporary files to guarantee they are cleaned up even if the script crashes.
5. **Root Privileges:** If a script modifies system states, include and invoke the `check_for_root` function to enforce execution via `sudo` or as root.

### Python Scripts
1. **Error Handling:** Wrap OS calls, file reads, and external requests in robust `try...except` blocks and provide safe fallback values.
2. **Standard Libraries First:** Avoid spawning shells (e.g., `os.popen`) for tasks that can be natively handled by reading system files (like `/proc/meminfo`) or using standard Python library modules.
3. **Concurrency:** When writing HTTP servers or network listeners, use non-blocking or threaded handlers (like `ThreadingHTTPServer`) to prevent blocking on concurrent requests.
