function New-ScoopShim {
    <#
    .SYNOPSIS
        Creates a Scoop-style shim and binary pair.
    .DESCRIPTION
        Generates a .shim metadata file and copies a launcher .exe to the 
        Scoop shims directory. This allows commands to be run globally 
        via the Scoop path.
    .PARAMETER Name
        The name of the command (e.g., 'up-pwsh').
    .PARAMETER TargetPath
        The full path to the executable the shim should run.
    .PARAMETER Arguments
        The arguments to pass to the target executable.
    .EXAMPLE
        New-ScoopShim -Name "up-pwsh" -TargetPath "winget.exe" -Arguments "upgrade --id Microsoft.PowerShell --force"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$TargetPath,

        [string]$Arguments = ""
    )

    process {
        $scoopRoot = Join-Path $env:USERPROFILE "scoop"
        $shimDir = Join-Path $scoopRoot "shims"
        $shimFile = Join-Path $shimDir "$Name.shim"
        $exeFile = Join-Path $shimDir "$Name.exe"
        
        # 1. Find a valid template shim EXE
        # All Scoop shims are identical launchers, so we can use any existing one.
        $templatePaths = @(
            (Join-Path $scoopRoot "apps\scoop\current\bin\shim.exe"),
            (Join-Path $shimDir "scoop.exe"),
            (Get-ChildItem -Path $shimDir -Filter "*.exe" | Select-Object -First 1 -ExpandProperty FullName)
        )

        $templateExe = $null
        foreach ($path in $templatePaths) {
            if ($path -and (Test-Path $path)) {
                $templateExe = $path
                break
            }
        }

        if ($null -eq $templateExe) {
            Write-Error "Could not find any Scoop shim template (.exe) in $shimDir or the Scoop apps folder."
            return
        }

        if (-not (Test-Path $shimDir)) {
            Write-Error "Scoop shim directory not found at $shimDir"
            return
        }

        try {
            # 2. Create the .shim metadata file
            $shimContent = "path = $TargetPath"
            if ($Arguments) { $shimContent += "`r`nargs = $Arguments" }
            Set-Content -Path $shimFile -Value $shimContent -Encoding Ascii

            # 3. Copy the template EXE to the new name
            Copy-Item -Path $templateExe -Destination $exeFile -Force
            
            Write-Host "Successfully created shim: $Name" -ForegroundColor Cyan
            Write-Host "Points to: $TargetPath $Arguments" -ForegroundColor Gray
        }
        catch {
            Write-Error "Failed to create shim: $($_.Exception.Message)"
        }
    }
}

Export-ModuleMember -Function New-ScoopShim
