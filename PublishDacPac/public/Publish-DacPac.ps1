function Publish-DacPac {
    <#
		.SYNOPSIS
        Publish-DacPac allows you to deploy a SQL Server Database using a DACPAC to a SQL Server instance.

		.DESCRIPTION
        Publishes a SSDT DacPac using a specified DacPac publish profile from your solution.
        Basically deploys the DACPAC by invoking SqlPackage.exe using a DacPac Publish profile

        This module requires SqlPackage.exe to be installed on the host machine.  This can be done by installing
        Microsoft SQL Server Management Studio from https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

		Written by (c) Dr. John Tunnicliffe, 2019 https://github.com/DrJohnT/PublishDacPac
		This PowerShell script is released under the MIT license http://www.opensource.org/licenses/MIT

        .PARAMETER DacPacPath
        Full path to your database DACPAC (e.g. C:\Dev\YourDB\bin\Debug\YourDB.dacpac)

        .PARAMETER DacPublishProfile
        Name of the DAC Publish Profile to be found in the same folder as your DACPAC (e.g. YourDB.CI.publish.xml)
        You can also provide the full path to an alternative DAC Publish Profile.

        .PARAMETER Server
        Name of the target server, including instance and port if required.  Note that this overwrites the server defined in
        the DAC Publish Profile

        .PARAMETER Database
        Normally, the database will be named the same as your DACPAC. However, by adding the -Database parameter, you can name the database anything you like.
        Note that this overwrites the database name defined in the DAC Publish Profile.

        .PARAMETER PreferredVersion
        Defines the preferred version of SqlPackage.exe you wish to use.  Use 'latest' for the latest version, or do not provide the parameter at all.
        Recommed you use the latest version of SqlPackage.exe as this will deploy to all previous version of SQL Server.

            latest = use the latest version of SqlPackage.exe
            150 = SQL Server 2019
            140 = SQL Server 2017
            130 = SQL Server 2016
            120 = SQL Server 2014
            110 = SQL Server 2012

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -Database 'NewDatabaseName' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml'

        Publish your database to server 'YourDBServer' with the name 'NewDatabaseName', using the DACPAC 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' and the DAC Publish profile 'YourDB.CI.publish.xml'.

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml'

        Simplist form

        .EXAMPLE
        Publish-DacPac -Server 'YourDBServer' -DacPacPath 'C:\Dev\YourDB\bin\Debug\YourDB.dacpac' -DacPublishProfile 'YourDB.CI.publish.xml' -PreferredVersion 130

        Request a specific version of SqlPackage.exe

        .NOTES
        This module requires SqlPackage.exe to be installed on the host machine.
        This can be done by installing Microsoft SQL Server Management Studio from https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017

    #>

	[CmdletBinding()]
	param
	(
        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DacPacPath,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $DacPublishProfile,

        [String] [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Server,

        [String] [Parameter(Mandatory = $false)]
        $Database,

        [String] [Parameter(Mandatory = $false)]
        [ValidateSet('150', '140', '130', '120', '110', 'latest')]
        $PreferredVersion = 'latest'
	)

	$global:ErrorActionPreference = 'Stop';

    try {
        if ([string]::IsNullOrEmpty($PreferredVersion)) {
            $PreferredVersion = 'latest';
        }
        # find the specific version of SqlPackage or the latest if not available
        $Version = Select-SqlPackageVersion -PreferredVersion $PreferredVersion;
        $SqlPackageExePath = Get-SqlPackagePath -Version $Version;

	    if (!(Test-Path -Path $SqlPackageExePath)) {
		    Write-Error "Could not find SqlPackage.exe in order to deploy the database DacPac!";
            Write-Warning "For install instructions, see https://www.microsoft.com/en-us/download/details.aspx?id=57784/";
            throw "Could not find SqlPackage.exe in order to deploy the database DacPac!";
	    }


        [String]$ProductVersion = (Get-Item $SqlPackageExePath).VersionInfo.ProductVersion;

	    if (!(Test-Path -Path $DacPacPath)) {
		    throw "DacPac path does not exist in $DacPacPath";
	    }

	    $DacPacName = Split-Path $DacPacPath -Leaf;
	    $OriginalDbName = $DacPacName -replace ".dacpac", ""
	    $DacPacFolder = Split-Path $DacPacPath -Parent;
        if ([string]::IsNullOrEmpty($Database)) {
		    $Database = $OriginalDbName;
	    }

        # figure out if we have a full path to the DAC Publish Profile or just the filename of the DAC Publish Profile in the same folder as the DACPAC
        if (Test-Path($DacPublishProfile)) {
            $DacPacPublishProfilePath = $DacPublishProfile;
        } else {
            try {
                $DacPacPublishProfilePath = Resolve-Path "$DacPacFolder\$DacPublishProfile";
            } catch {
                throw "DAC Publish Profile does not exist";
            }
        }

        $ProfileName = Split-Path $DacPacPublishProfilePath -Leaf;

        Write-Output "Publish-DacPac resolved the following parameters:";
        Write-Output "DacPacPath         : $DacPacName from $DacPacFolder";
        Write-Output "DacPublishProfile  : $ProfileName from $DacPacPublishProfilePath";
        Write-Output "Server             : $Server" ;
        Write-Output "Database           : $Database";
        Write-Output "SqlPackage.exe     : $Version (v$ProductVersion) from $SqlPackageExePath" ;
        Write-Output "Following output generated by SqlPackage.exe";
        Write-Output "==============================================================================";

		[xml]$DacPacDacPublishProfile = [xml](Get-Content $DacPacPublishProfilePath);
		$DacPacDacPublishProfile.Project.PropertyGroup.TargetDatabaseName = "$Database";
		$DacPacDacPublishProfile.Project.PropertyGroup.TargetConnectionString = "Data Source=$Server;Integrated Security=True";
		$DacPacUpdatedProfilePath = "$DacPacFolder\$OriginalDbName.deploy.publish.xml";
		$DacPacDacPublishProfile.Save($DacPacUpdatedProfilePath);

		$global:lastexitcode = 0;

        if (!(Ping-SqlServer -Server $Server)) {
            throw "Server '$Server' does not exist!";
        } else {
            Write-Verbose "Publish-DacPac: Deploying database '$Database' to server '$Server' using DacPac '$DacPacName'"

            $ArgList = @(
                "/Action:Publish",
                "/SourceFile:$DacPacPath",
                "/Profile:$DacPacUpdatedProfilePath"
            );
            Invoke-ExternalCommand -Command "$SqlPackageExePath" -Arguments $ArgList;
        }
    } catch {
        Write-Error "Error: $_";
    }
}
