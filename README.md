# PowerShell Modules

A collection of useful, high-quality PowerShell modules for automation and productivity.

## 📦 Modules

### 1. psdict
A pure PowerShell client for the DICT protocol (RFC 2229). It allows you to query dictionary servers (like `dict.org`) directly from your command line without any external dependencies.

**Features:**
*   **No dependencies:** Uses .NET `TcpClient` directly.
*   **Interactive:** If a word isn't found in the default database, it offers a list of other available databases.
*   **Scriptable:** easy to integrate into other scripts.

**Usage:**
```powershell
# Simple lookup
psdict "automation"

# List available databases
psdict -ListAvailableDatabases

# Search in a specific database
psdict "kernel" -Database "jargon"
```

### 2. Start-ForegroundProcess
A robust utility to launch processes and forcefully bring them to the foreground. This solves the common issue where automated scripts launch windows that get stuck behind other applications.

**Features:**
*   **Window Focus:** Uses Win32 APIs (P/Invoke) to attach to the process and force it to the top.
*   **Output Capture:** Correctly captures `stdout` and `stderr` from the process, which usually gets lost when using complex `Start-Process` configurations.
*   **Wait Support:** Can wait for the process to exit, just like `Start-Process`.

**Usage:**
```powershell
# Launch Notepad and force it to the front
Start-ForegroundProcess -FilePath "notepad.exe"

# Run a command, wait for it, and capture output
Start-ForegroundProcess -FilePath "cmd.exe" -ArgumentList "/c echo Hello" -Wait
```

### 3. Set-ClipboardFile
A utility to set files to the Windows clipboard so they can be pasted into File Explorer, emails, or other applications.

**Features:**
*   **Explorer Integration:** Files are copied as a "FileDropList," meaning they behave exactly like files copied from within Explorer (Ctrl+C).
*   **Batch Support:** Copy multiple files at once using wildcards.
*   **Alias:** `scbf` (similar to `scb` for `Set-Clipboard`).
*   **Detailed Output:** Lists the files copied by default (use `-Quiet` to suppress).

**Usage:**
```powershell
# Copy a single file
Set-ClipboardFile -Path "C:\MyFolder\Report.pdf"

# Copy all images, listing them as they are copied
scbf *.jpg

# Copy silently
scbf *.png -Quiet
```

## 🧪 Testing

A test script is included in `tests/Test-Comparison.ps1` to verify the behavior of `Start-ForegroundProcess` against standard PowerShell commands.

## 📜 Credits

### Set-ClipboardFile
The core logic for `Set-ClipboardFile` was adapted from a [Stack Overflow answer](https://stackoverflow.com/a/71616862) by [Eric Eskildsen](https://stackoverflow.com/users/3806701/eric-eskildsen), licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## 📝 License

This project is licensed under the [MIT License](LICENSE).
