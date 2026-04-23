# New-ScoopShim

A utility to create Scoop-style shims and binary pairs.

## 📦 Features

*   **Global Command Creation:** Generates a .shim metadata file and copies a launcher .exe to the Scoop shims directory.
*   **Scoop Integration:** Leverages the existing Scoop shim architecture to make commands globally accessible via the Scoop path.
*   **Fully Documented:** Includes built-in PowerShell help documentation.

## 🚀 Usage

```powershell
# Create a shortcut for updating PowerShell via winget
New-ScoopShim -Name "up-pwsh" `
              -TargetPath "winget.exe" `
              -Arguments "upgrade --id Microsoft.PowerShell --source winget --force"

# After running, 'up-pwsh' will be available globally from any terminal.
up-pwsh
```

## 🛠️ How it Works

The module follows the Scoop Shim Architecture:
1.  **Metadata:** It creates a `.shim` text file containing the target path and arguments.
2.  **Launcher:** It copies `scoop.exe` (which acts as a generic shim launcher) to a new executable name that matches your shim.
3.  **Pathing:** Since `~/scoop/shims` is typically in your `$env:PATH`, the new command becomes available immediately.
