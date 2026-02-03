function Get-GitUsrBinPath {
    try {
        $gitPath = (Get-Command git.exe -ErrorAction Stop).Source
        if ($gitPath -like "*\scoop\shims\*") {
            $scoopRoot = Split-Path (Split-Path $gitPath -Parent) -Parent
            return Join-Path $scoopRoot "apps\git\current\usr\bin"
        }
        $root = Split-Path (Split-Path $gitPath -Parent) -Parent
        return Join-Path $root "usr\bin"
    } catch { return $null }
}

function gbin {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            $gitPath = (Get-Command git.exe -ErrorAction SilentlyContinue).Source
            if (!$gitPath) { return $null }
            
            if ($gitPath -like "*\scoop\shims\*") {
                $root = Split-Path (Split-Path $gitPath -Parent) -Parent
                $bin = Join-Path $root "apps\git\current\usr\bin"
            } else {
                $root = Split-Path (Split-Path $gitPath -Parent) -Parent
                $bin = Join-Path $root "usr\bin"
            }

            if (Test-Path $bin) {
                $options = [System.Collections.Generic.List[string]]::new()
                if ("--list" -like "$wordToComplete*") { $options.Add("--list") }
                if ("--path" -like "$wordToComplete*") { $options.Add("--path") }

                Get-ChildItem -Path $bin -Filter "$wordToComplete*.exe" | 
                    ForEach-Object { $options.Add($_.BaseName) }

                return $options | ForEach-Object { 
                    # Using 'Command' type here helps suppress local file system suggestions
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'Command', $_) 
                }
            }
        })]
        [string]$Utility,

        # This parameter catches piped objects
        [Parameter(ValueFromPipeline=$true)]
        $InputObject,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    begin {
        $binPath = Get-GitUsrBinPath
        if (-not $binPath) { Write-Error "Git usr/bin not found."; return }

        # Handle non-executable flags
        if ($Utility -eq "--list") {
            Get-ChildItem -Path $binPath -Filter "*.exe" | 
                Select-Object -ExpandProperty BaseName | 
                Format-Wide -Column 5
            return
        }
        if ($Utility -eq "--path") { $binPath; return }

        $exePath = Join-Path $binPath "$Utility.exe"
        if (-not (Test-Path $exePath)) {
            Write-Host "[gbin] Error: '$Utility' not found." -ForegroundColor Red
            return
        }
    }

    process {
        # If the utility is a meta-command (--list, etc), skip execution
        if ($Utility -like "--*") { return }

        if ($null -ne $InputObject) {
            # If we have pipeline input, pipe the current object to the exe
            $InputObject | & $exePath $Arguments
        } 
        elseif (-not $MyInvocation.ExpectingInput) {
            # If there is NO pipeline expected at all, run normally
            & $exePath $Arguments
        }
    }
}

Export-ModuleMember -Function gbin