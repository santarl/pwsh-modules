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
            
            # Use the helper function inside the completer
            $gitPath = (Get-Command git.exe -ErrorAction SilentlyContinue).Source
            if (!$gitPath) { return $null }
            
            # Resolve path (Redundant but necessary for scope isolation)
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
                    [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) 
                }
            }
        })]
        [string]$Utility,

        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )

    process {
        $binPath = Get-GitUsrBinPath
        if (-not $binPath) { Write-Error "Git usr/bin not found."; return }

        switch ($Utility) {
            "--list" {
                Get-ChildItem -Path $binPath -Filter "*.exe" | 
                    Select-Object -ExpandProperty BaseName | 
                    Format-Wide -Column 5
                return
            }
            "--path" { $binPath; return }
        }

        $exePath = Join-Path $binPath "$Utility.exe"
        if (Test-Path $exePath) {
            & $exePath $Arguments
        } else {
            Write-Host "[gbin] Error: '$Utility' not found. Try 'gbin --list'" -ForegroundColor Red
        }
    }
}

Export-ModuleMember -Function gbin