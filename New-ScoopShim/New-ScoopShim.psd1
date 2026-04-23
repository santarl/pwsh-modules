@{
    RootModule = 'New-ScoopShim.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-b6c7-d8e9f0a1b2c3'
    Author = 'santarl'
    CompanyName = 'santarl'
    Copyright = '(c) 2026 santarl. All rights reserved.'
    Description = 'Generates a .shim metadata file and copies a launcher .exe to the Scoop shims directory. This allows commands to be run globally via the Scoop path.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('New-ScoopShim')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()

    # Gallery Metadata
    PrivateData = @{
        PSData = @{
            Tags = @('Scoop', 'Shim', 'Windows', 'Utility', 'Automation')
            LicenseUri = 'https://github.com/santarl/pwsh-modules/blob/main/LICENSE'
            ProjectUri = 'https://github.com/santarl/pwsh-modules'
            ReleaseNotes = 'Initial release.'
        }
    }
}
