@{
    RootModule = 'Start-ForegroundProcess.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'b2c3d4e5-f6a7-4b8c-9d0e-1a2b3c4d5e6f'
    Author = 'santarl'
    CompanyName = 'santarl'
    Copyright = '(c) 2026 santarl. All rights reserved.'
    Description = 'A robust utility to launch processes and forcefully bring them to the foreground.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Start-ForegroundProcess')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()

    PrivateData = @{
        PSData = @{
            Tags = @('Process', 'Foreground', 'Focus', 'Windows', 'Automation')
            LicenseUri = 'https://github.com/santarl/pwsh-modules/blob/main/LICENSE'
            ProjectUri = 'https://github.com/santarl/pwsh-modules'
        }
    }
}
