# This is the full content for the file:
# ~\Scripts\Modules\StartForegroundProcess\StartForegroundProcess.psm1

function Start-ForegroundProcess {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string[]]$ArgumentList,

        [switch]$Wait,

        [switch]$PassThru
    )

    # Define Win32 API functions (no changes here).
    if (-not ("MyWin32" -as [type])) {
        $cSharpCode = @"
        using System;
        using System.Runtime.InteropServices;
        public class MyWin32 {
            [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
            [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
            [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr ProcessId);
            [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
            [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool SetForegroundWindow(IntPtr hWnd);
            [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool BringWindowToTop(IntPtr hWnd);
            [DllImport("user32.dll")] [return: MarshalAs(UnmanagedType.Bool)] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            public const int SW_RESTORE = 9;
        }
"@
        Add-Type -TypeDefinition $cSharpCode -PassThru | Out-Null
    }

    $outputEvent = $null
    $errorEvent = $null

    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $FilePath
        $startInfo.Arguments = $ArgumentList -join ' '
        $startInfo.UseShellExecute = $false
        $startInfo.RedirectStandardOutput = $true
        $startInfo.RedirectStandardError = $true
        $startInfo.CreateNoWindow = $true
        $startInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8
        $startInfo.StandardErrorEncoding = [System.Text.Encoding]::UTF8

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo

        $onOutput = {
            if ($EventArgs.Data) {
                Write-Host $EventArgs.Data
            }
        }
        $onError =  {
            if ($EventArgs.Data) {
                Write-Error $EventArgs.Data
            }
        }
        
        $outputEvent = Register-ObjectEvent -InputObject $process -EventName "OutputDataReceived" -Action $onOutput
        $errorEvent  = Register-ObjectEvent -InputObject $process -EventName "ErrorDataReceived"  -Action $onError

        if (-not $process.Start()) {
            Write-Warning "Failed to start process: $FilePath"
            return
        }

        # This tells the process to start raising events for its output.
        $process.BeginOutputReadLine()
        $process.BeginErrorReadLine()
        
        # Poll for the main window. This loop is interruptible by Ctrl+C.
        while ($process.MainWindowHandle -eq [IntPtr]::Zero -and !$process.HasExited) {
            Start-Sleep -Milliseconds 200
        }

        # Forcefully bring the new window to the foreground (no changes here).
        if (!$process.HasExited) {
            $targetHwnd = $process.MainWindowHandle; $currentThreadId = [MyWin32]::GetCurrentThreadId(); $foregroundHwnd = [MyWin32]::GetForegroundWindow(); $foregroundThreadId = [MyWin32]::GetWindowThreadProcessId($foregroundHwnd, [IntPtr]::Zero)
            try {
                [MyWin32]::AttachThreadInput($currentThreadId, $foregroundThreadId, $true) | Out-Null
                [MyWin32]::ShowWindow($targetHwnd, [MyWin32]::SW_RESTORE) | Out-Null
                [MyWin32]::BringWindowToTop($targetHwnd) | Out-Null
                [MyWin32]::SetForegroundWindow($targetHwnd) | Out-Null
            } finally {
                [MyWin32]::AttachThreadInput($currentThreadId, $foregroundThreadId, $false) | Out-Null
            }
        }

        if ($Wait) {
            $process.WaitForExit()
        }
        if ($PassThru) {
            return $process
        }
    }
    finally {
        # CRITICAL: Always clean up the event subscriptions.
        if ($outputEvent) { Unregister-Event -SubscriptionId $outputEvent.Id }
        if ($errorEvent) { Unregister-Event -SubscriptionId $errorEvent.Id }
    }
}

# Make the function available for import.
Export-ModuleMember -Function Start-ForegroundProcess