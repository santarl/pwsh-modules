@{
    RootModule = 'Set-ClipboardFile.psm1'
    ModuleVersion = '1.0.1'
    GUID = '76e27a6f-1234-5678-90ab-cdef12345678'
    Author = 'Atef'
    CompanyName = 'Atef'
    Copyright = '(c) 2026 Atef. All rights reserved.'
    Description = 'Sets actual files to the Windows clipboard (FileDropList) for pasting into Explorer, emails, or other apps. Unlike Set-Clipboard, this handles the files themselves, not just their text paths.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Set-ClipboardFile')
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @('scbf')

    # Gallery Metadata
    PrivateData = @{
        PSData = @{
            Tags = @('Clipboard', 'File', 'Windows', 'Utility', 'Copy', 'Paste')
            LicenseUri = 'https://github.com/santarl/pwsh-modules/blob/main/LICENSE'
            ProjectUri = 'https://github.com/santarl/pwsh-modules'
            ReleaseNotes = 'Initial release.'
        }
    }
}