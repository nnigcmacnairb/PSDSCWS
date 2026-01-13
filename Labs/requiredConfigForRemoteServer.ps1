Invoke-Command -ComputerName MS -ScriptBlock {
    Install-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module xWebAdministration -Force -Scope AllUsers
    Install-Module NetworkingDsc     -Force -Scope AllUsers
    Install-Module WebAdministrationDsc -MinimumVersion 4.2.1 -force -Scope AllUsers
}
  