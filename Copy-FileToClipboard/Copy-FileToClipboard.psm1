function Copy-FileToClipboard {
    <#
    .SYNOPSIS
        Copies one or more files to the Windows clipboard as a FileDropList.
    
    .DESCRIPTION
        This function uses the .NET Windows Forms API to place files on the clipboard. 
        Once copied, these files can be pasted into File Explorer or other applications using Ctrl+V.
    
    .PARAMETER Path
        The path to the file(s) to copy. Supports wildcards.
    
    .PARAMETER LiteralPath
        The literal path to the file(s) to copy. Use this if the path contains special characters like square brackets.
    
    .EXAMPLE
        Copy-FileToClipboard -Path .\MyDocument.pdf
        Copies a single document to the clipboard.
    
    .EXAMPLE
        Copy-FileToClipboard -Path *.jpg
        Copies all JPG files in the current directory to the clipboard.
    #>
    [CmdletBinding(DefaultParameterSetName = "Path")]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ParameterSetName = "Path")]
        [string[]]$Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "LiteralPath")]
        [Alias("PSPath")]
        [string[]]$LiteralPath
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
            Write-Host "Successfully copied $($fileCollection.Count) file(s) to the clipboard." -ForegroundColor Green
        }
    }
}

Export-ModuleMember -Function Copy-FileToClipboard
