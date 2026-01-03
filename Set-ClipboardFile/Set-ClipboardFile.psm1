function Set-ClipboardFile {
    <#
    .SYNOPSIS
        Sets the Windows clipboard to the specified file(s) (FileDropList).
    
    .DESCRIPTION
        This function uses the .NET Windows Forms API to place files on the clipboard. 
        Once set, these files can be pasted into File Explorer or other applications using Ctrl+V.

        Source - https://stackoverflow.com/a/71616862
        Posted by Eric Eskildsen, modified by community.
        Retrieved 2026-01-04, License - CC BY-SA 4.0
    
    .PARAMETER Path
        The path to the file(s) to copy. Supports wildcards.
    
    .PARAMETER LiteralPath
        The literal path to the file(s) to copy. Use this if the path contains special characters like square brackets.
    
    .PARAMETER Quiet
        Suppresses the output confirming which files were copied.
    
    .EXAMPLE
        Set-ClipboardFile -Path .\MyDocument.pdf
        Sets the clipboard to a single document.
    
    .EXAMPLE
        Set-ClipboardFile -Path *.jpg
        Sets the clipboard to all JPG files in the current directory.
    #>
    [CmdletBinding(DefaultParameterSetName = "Path")]
    [Alias('scbf')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Path")]
        [Alias("FullName")]
        [string[]]$Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "LiteralPath")]
        [Alias("PSPath")]
        [string[]]$LiteralPath,

        [Parameter()]
        [Alias('Q')]
        [switch]$Quiet
    )

    begin {
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        } catch {
            Write-Error "Could not load System.Windows.Forms. This module requires a Windows environment with desktop features."
            return
        }
        $fileCollection = [System.Collections.Specialized.StringCollection]::new()
    }

    process {
        $resolvedItems = if ($PSCmdlet.ParameterSetName -eq "Path") {
            Get-Item -Path $Path -ErrorAction SilentlyContinue
        } else {
            Get-Item -LiteralPath $LiteralPath -ErrorAction SilentlyContinue
        }

        if ($null -eq $resolvedItems) {
            Write-Warning "No files found matching the provided path."
            return
        }

        foreach ($item in $resolvedItems) {
            [void]$fileCollection.Add($item.FullName)
        }
    }

    end {
        if ($fileCollection.Count -gt 0) {
            # Note: SetFileDropList replaces the current clipboard content.
            [System.Windows.Forms.Clipboard]::SetFileDropList($fileCollection)
            
            if (-not $Quiet) {
                Write-Host "Copied to clipboard:" -ForegroundColor Cyan
                foreach ($file in $fileCollection) {
                    Write-Host " + $file" -ForegroundColor Green
                }
            }
        }
    }
}

Export-ModuleMember -Function Set-ClipboardFile -Alias scbf