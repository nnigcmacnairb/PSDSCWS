$modulePath = Read-Host -Prompt 'C:\PShell\Labs\modules'
foreach ($module in (Get-ChildItem $modulePath))
{
   $versionedFolder = $module | Get-ChildItem -Directory | Select-Object -First 1
   $archiveName = '{0}_{1}.zip' -f $module.BaseName, $versionedFolder.BaseName
   Compress-Archive -Path "$($versionedFolder.FullName)/*" -DestinationPath $archiveName
}




$modulePath = Read-Host -Prompt 'C:\PShell\Labs\modules'
foreach ($module in (Get-ChildItem $modulePath))
{
   $versionedFolder = $module | Get-ChildItem -Directory | Select-Object -First 1
   $archiveName = '{0}_{1}.zip' -f $module.BaseName, $versionedFolder.BaseName
   Compress-Archive -Path "$($versionedFolder.FullName)/*" -DestinationPath $archiveName
   $content = Set-AzStorageBlobContent -File $archiveName -CloudBlobContainer $container.CloudBlobContainer -Blob $archiveName -Context $account.Context -Force -ErrorAction Stop
   $token = New-AzStorageBlobSASToken -CloudBlob $content.ICloudBlob -StartTime (Get-Date) -ExpiryTime (Get-Date).AddYears(5) -Protocol HttpsOnly -Context $account.Context -Permission r -ErrorAction Stop
   $uri = '{4}://{3}.blob.core.windows.net/{0}/{1}{2}' -f $container.Name, $fileName, $token, $account.StorageAccountName, 'https'

   New-AzAutomationModule -Name $module.BaseName -ContentLinkUri $uri -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName
}





#$modulePath = Read-Host -Prompt 'Path to your modules'
#$modulePath = [string[]](Get-InstalledModule -Name NetworkingDsc, WebAdministrationDsc).InstalledLocation | Split-Path -Parent
$modulePath = "C:\PShell\Labs\modules\WebAdministrationDsc", "C:\PShell\Labs\modules\NetworkingDsc"
$account = Get-AzStorageAccount
$resourceGroup = 'DSCRGlod58268006'
$automationAccountName = (Get-AzAutomationAccount).AutomationAccountName
$storageContainerName = 'modules'
if ( -not $account)
{
   Write-Error -Message "There's no storage account..."
   return
}
$container = Get-AzStorageContainer -Name $storageContainerName -Context $account.Context -ErrorAction SilentlyContinue
if (-not $container)
{
   $container = New-AzStorageContainer -Name $storageContainerName -Context $account.Context -ErrorAction Stop
}

foreach ($module in (Get-Item -Path $modulePath))
{
   $versionedFolder = $module | Get-ChildItem -Directory | Select-Object -First 1
   $archiveName = '{0}_{1}.zip' -f $module.BaseName, $versionedFolder.BaseName
   Compress-Archive -Path "$($versionedFolder.FullName)/*" -DestinationPath $archiveName -Force
   $content = Set-AzStorageBlobContent -File $archiveName -CloudBlobContainer $container.CloudBlobContainer -Blob $archiveName -Context $account.Context -Force -ErrorAction Stop
   $uri = New-AzStorageBlobSASToken -CloudBlob $content.ICloudBlob -StartTime (Get-Date) -ExpiryTime (Get-Date).AddYears(5) -Protocol HttpsOnly -Context $account.Context -Permission r -FullUri -ErrorAction Stop
   New-AzAutomationModule -Name $module.BaseName -ContentLinkUri $uri -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName -Verbose
}



Install-Module -Name Az.Resources -Force -Verbose
$ResourceGroupName = (Get-AzResourceGroup).ResourceGroupName 
$User = "CustomAppPool1"
$Password = ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $Password
New-AzAutomationCredential -AutomationAccountName $automationAccountName -Name "CustomAppPool1" -Value $Credential -ResourceGroupName $R$ResourceGroupName


Credential = Get-AutomationPSCredential -Name "$($site.AppPool.CredentialName)" -ResourceGroupName $R$ResourceGroupName 


Import-AzAutomationDscConfiguration -SourcePath C:\PShell\Labs\WebServer.ps1 -Published -ResourceGroupName DSCRGlod58268006 -AutomationAccountName (Get-AzAutomationAccount).AutomationAccountName -Force


Start-AzAutomationDscCompilationJob -ConfigurationName WebServer -ConfigurationData (Import-LocalizedData -BaseDirectory C:\PShell\Labs -FileName configurationdata.psd1 -SupportedCommand New-Object,ConvertTo-SecureString) -ResourceGroupName DSCRGlod58268006 -AutomationAccountName (Get-AzAutomationAccount).AutomationAccountName

Get-AzAutomationDscOnboardingMetaconfig -ComputerName MS -ResourceGroupName DSCRGlod58268006 -AutomationAccountName (Get-AzAutomationAccount).AutomationAccountName -OutputFolder .