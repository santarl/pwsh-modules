# GitBinProxy

A lightweight PowerShell module that proxies the GNU utilities included with **Git for Windows** (like `sed`, `awk`, `grep`, `ls`, etc.) into a single command: `gbin`.

## Why?
Git for Windows comes with over 200+ Unix utilities, but adding them all to your system PATH often causes conflicts with Windows native commands (like `find.exe` or `sort.exe`). `GitBinProxy` gives you access to them all without polluting your environment.

## Features
- **Smart Discovery:** Automatically finds Git via `scoop` or standard installations.
- **Linux-style UI:** Supports `--list`, `--help`, and `--path`.
- **Intelligent Tab Completion:** Fast, exclusive completion for all 200+ binaries.

## Usage
```powershell
# List all available utilities
gbin --list

# Use a utility
gbin sed 's/foo/bar/g' file.txt
gbin awk '{print $1}' data.log