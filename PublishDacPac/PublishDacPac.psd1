#
# Module manifest for module 'PublishDacPac'
#
# Generated by: Dr. John Tunnicliffe
#
# Generated on: 20/03/2019
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PublishDacPac.psm1'

# Version number of this module.
ModuleVersion = '1.0.3'

# ID used to uniquely identify this module
GUID = '12957ebe-7de8-4bf6-9b19-c07596b04f9f'

# Author of this module
Author = 'Dr. John Tunnicliffe'

# Company or vendor of this module
CompanyName = 'Decision Analytics'

# Copyright statement for this module
Copyright = '(c) 2019 Dr. John Tunnicliffe. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Publish your SQL Database DACPAC using a DAC Publish Profile'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = @(
    'Publish-DacPac',
    'Select-SqlPackageVersion',
    'Get-SqlPackagePath',
    'Ping-SqlDatabase',
    'Ping-SqlServer',
    'Find-SqlPackageLocations',
    'Invoke-ExternalCommand'
)

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @("SSDT","deployment","DACPAC","deploy","publish","SQL","database","DAC","sqlserver","Profile","Azure","DevOps","SqlPackage","powershell","pipeline","release","data-tier","on-premise","azure","automation")

        # A URL to the license for this module.
        LicenseUri = 'https://raw.githubusercontent.com/DrJohnT/PublishDacPac/master/PublishDacPac/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/DrJohnT/PublishDacPac'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/DrJohnT/PublishDacPac/releases/tag/1.0.3'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/DrJohnT/PublishDacPac/wiki'

}

