# New-ScoopShim

A utility to create Scoop-style shims and binary pairs.

## 🤔 Why?

*   **Avoid PATH Flooding:** Instead of adding dozens of individual application folders to your system `PATH`, you keep them all in one place (`~/scoop/shims`).
*   **True Global Availability:** Unlike PowerShell aliases or `doskey` (CMD) aliases, shims are actual `.exe` files. This means:
    *   They work from the **Windows Run Dialog** (`Win+R`).
    *   They work from **any shell** (CMD, PowerShell, Bash, etc.).
    *   They are visible to **any application** (IDE terminals, build scripts, etc.).
*   **Decoupled from PWSH:** You can trigger these commands even if you haven't loaded a PowerShell profile or if you are working in a raw environment without a valid PowerShell setup.
*   **Convenience:** It mimics the clean, "one tool for one job" philosophy found in Arch Linux and other high-productivity environments.

## 📦 Features

*   **Global Command Creation:** Generates a .shim metadata file and copies a launcher .exe to the Scoop shims directory.
*   **Scoop Integration:** Leverages the existing Scoop shim architecture to make commands globally accessible via the Scoop path.
*   **Fully Documented:** Includes built-in PowerShell help documentation.

## 🚀 Usage

```powershell
# Create a shortcut for updating PowerShell via winget
New-ScoopShim -Name "Update-PWSH" `
              -TargetPath "winget.exe" `
              -Arguments "upgrade --id Microsoft.PowerShell --source winget --force"

# After running, 'Update-PWSH' will be available globally from any terminal or Win+R.
Update-PWSH
```

## 🛠️ How it Works

The module follows the Scoop Shim Architecture:
1.  **Metadata:** It creates a `.shim` text file containing the target path and arguments.
2.  **Launcher:** It copies an existing shim (like `7z.exe` or `scoop.exe`) to a new executable name that matches your shim.
3.  **Pathing:** Since `~/scoop/shims` is in your `$env:PATH`, the new command becomes available immediately.
