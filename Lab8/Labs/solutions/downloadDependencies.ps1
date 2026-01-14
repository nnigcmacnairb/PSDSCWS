Get-PackageProvider -Name Nuget -ForceBootstrap -Force

Install-Module PackageManagement, PowerShellGet, PSDepend -Force -SkipPublisherCheck -Repository PSGallery

Invoke-PSDepend -Path $PSScriptRoot -Force