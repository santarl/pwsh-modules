#Requires -Version 5.1

# -----------------------------------------------------------------------------
# Private Helper Functions (Internal to the module)
# -----------------------------------------------------------------------------

# Handles the raw TCP connection to the DICT server.
function Invoke-DictRequest {
    param ([string]$Server, [string]$Command)
    $Port = 2628
    $TcpClient = New-Object System.Net.Sockets.TcpClient
    try {
        $ConnectResult = $TcpClient.ConnectAsync($Server, $Port)
        if (-not $ConnectResult.Wait(5000)) { throw "Connection to '$Server' timed out." }

        $Stream = $TcpClient.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Reader = New-Object System.IO.StreamReader($Stream)

        $Writer.WriteLine($Command)
        $Writer.Flush()

        $Response = ""
        while (($Line = $Reader.ReadLine()) -ne $null) {
            $Response += "$Line`n"
            # === THE CORRECT FIX ===
            # Break only on the final success code (250) or any failure code (starts with 5).
            # This correctly ignores the 220 welcome banner and handles the 552 failure case.
            if ($Line.StartsWith('250') -or $Line.StartsWith('5')) {
                break
            }
        }
        return $Response.Split("`n")
    }
    finally {
        if ($TcpClient) { $TcpClient.Close() }
        if ($Writer) { $Writer.Dispose() }
        if ($Reader) { $Reader.Dispose() }
    }
}

# Fetches and parses the list of available databases into objects.
function Get-PsDictDatabases {
    param ([string]$Dictionary)
    $Response = Invoke-DictRequest -Server $Dictionary -Command "SHOW DB"
    $databases = foreach ($line in $Response) {
        if ($line -match '^\s*(\S+)\s+"(.*)"') {
            [PSCustomObject]@{
                Name        = $Matches[1]
                Description = $Matches[2]
            }
        }
    }
    return $databases
}

# Prompts the user to select one or more databases, using Out-ConsoleGridView if available.
function Select-PsDictDatabase {
    param ([string]$Dictionary)
    Write-Host "`nWord not found in WordNet (wn)."
    $databases = Get-PsDictDatabases -Dictionary $Dictionary
    
    # Proactively try to load the modules containing Out-ConsoleGridView
    Import-Module Microsoft.PowerShell.ConsoleGuiTools -ErrorAction SilentlyContinue
    Import-Module Microsoft.PowerShell.GraphicalHost -ErrorAction SilentlyContinue

    $hasGridView = (Get-Command Out-ConsoleGridView -ErrorAction SilentlyContinue)
    
    if ($hasGridView) {
        Write-Host "Please select one or more databases from the grid to search instead."
        $selection = $databases | Out-ConsoleGridView -Title "Select Databases"
        return $selection.Name
    }
    else {
        # Fallback to a simple text menu
        Write-Host "Please select a database to search instead:`n"
        for ($i = 0; $i -lt $databases.Count; $i++) {
            Write-Host ("  {0,2}: {1,-20} {2}" -f ($i + 1), $databases[$i].Name, $databases[$i].Description)
        }
        
        $choice = -1
        while ($choice -lt 1 -or $choice -gt $databases.Count) {
            $input = Read-Host "`nEnter a number (1-$($databases.Count))"
            $choice = $input -as [int]
        }
        return $databases[$choice - 1].Name
    }
}

# Performs a search and prints the results. Returns $true if found, $false if not.
function Invoke-PsDictSearch {
    param ([string]$Word, [string]$Database, [string]$Dictionary)
    
    $Command = "DEFINE $Database `"$Word`""
    Write-Verbose "Sending command to '$Dictionary': $Command"
    $Response = Invoke-DictRequest -Server $Dictionary -Command $Command
    Write-Verbose "Raw response from server:`n$($Response | Out-String)"

    if ($Response -match "^552 ") { return $false }

    $definitionFound = $false
    foreach ($line in $Response) {
        $trimmedLine = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmedLine) -or $trimmedLine -match "^(150|151|220|250)" -or $trimmedLine -eq ".") {
            continue
        }
        $definitionFound = $true
        Write-Host $trimmedLine
    }
    return $definitionFound
}

# Displays the help text.
function Show-PsDictHelp {
    $HelpText = @"
Usage:
    psdict <Word> [-Database <string>] [-Dictionary <string>]
    psdict -ListAvailableDatabases [-Dictionary <string>]
    psdict -Help

DESCRIPTION:
    Queries a DICT protocol server for word definitions.
    If no database is specified, it defaults to WordNet (wn).
    If the word is not found, it interactively prompts you to search other databases.

PARAMETERS:
    -Word <string>
    The word you want to look up.

    -ListAvailableDatabases
    Lists all available databases on the server.

    -Database <string>
    The specific database to search in (e.g., "jargon", "web1913", "all").
    This overrides the default interactive behavior.

    -Dictionary <string>
    The dictionary server to use. Default is 'dict.org'.

    -Help
    Displays this help message. Aliases: -h.

EXAMPLES:
    psdict "magic"
    psdict "recursion" -Database "jargon"
    psdict -ListAvailableDatabases
    psdict -h
"@
    Write-Host $HelpText
}

# -----------------------------------------------------------------------------
# Public Function (The ONLY function exported from the module)
# -----------------------------------------------------------------------------
function psdict {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param (
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'Search')]
        [string]$Word,
        [Parameter(Mandatory, ParameterSetName = 'List')]
        [switch]$ListAvailableDatabases,
        [Alias('h')]
        [Parameter(Mandatory, ParameterSetName = 'Help')]
        [switch]$Help,
        [Parameter(ParameterSetName = 'Search')]
        [Parameter(ParameterSetName = 'List')]
        [string]$Dictionary = "dict.org",
        [Parameter(ParameterSetName = 'Search')]
        [string]$Database
    )

    try {
        switch ($PSCmdlet.ParameterSetName) {
            'Search' {
                if ($PSBoundParameters.ContainsKey('Database')) {
                    $found = Invoke-PsDictSearch -Word $Word -Database $Database -Dictionary $Dictionary
                    if (-not $found) {
                        Write-Warning "No definition found for '$Word' in the '$Database' database."
                    }
                }
                else {
                    $foundInWn = Invoke-PsDictSearch -Word $Word -Database 'wn' -Dictionary $Dictionary
                    
                    if (-not $foundInWn) {
                        $selectedDbs = Select-PsDictDatabase -Dictionary $Dictionary
                        if ($selectedDbs) {
                            $dbString = $selectedDbs -join ','
                            Write-Host "`n--- Searching in '$dbString' ---"
                            $found = Invoke-PsDictSearch -Word $Word -Database $dbString -Dictionary $Dictionary
                            if (-not $found) {
                                Write-Warning "No definition found for '$Word' in the selected database(s)."
                            }
                        }
                    }
                }
            }
            'List' {
                $databases = Get-PsDictDatabases -Dictionary $Dictionary
                Write-Host "Available Databases from '$Dictionary':`n"
                foreach ($db in $databases) {
                    "  {0,-20} {1}" -f $db.Name, $db.Description
                }
            }
            'Help' {
                Show-PsDictHelp
            }
        }
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}

# Export ONLY the main function for the user to interact with.
Export-ModuleMember -Function psdict