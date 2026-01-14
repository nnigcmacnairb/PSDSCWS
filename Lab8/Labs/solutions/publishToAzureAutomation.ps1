#region Connection to Azure
$credential = [pscredential]::new('User1-58274048@lodsasdoutlook.onmicrosoft.com', ('G*5k$pN7Hqq!' | ConvertTo-SecureString -AsPlainText -Force))
Connect-AzAccount -Credential $credential
$root = Resolve-Path "$PSScriptRoot\.."
$env:PSModulePath = "$((Resolve-Path -Path (Join-Path $root output/modules) -ErrorAction Stop).Path);$env:PSModulePath"
#endregion

#region MOF import
$automationAccountName = 'CLOUDSLICEAUTO'
$resourceGroup = 'DSCRGlod58274048'

foreach ($mof in (Get-ChildItem -Path (Join-Path $root output) -Filter *.mof))
{
    Import-AzAutomationDscNodeConfiguration -Path $mof.FullName -ConfigurationName Prod -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroup -Force -IncrementNodeConfigurationBuild
}
#endregion

#region Module import
$automationAccountName = 'CLOUDSLICEAUTO'
$storageAccountName = 'CLOUDSLICESTORAGE'
$resourceGroup = 'DSCRGlod58274048'
$containerName = 'modules'
$modulePath = Join-Path $root output/modules

$account = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue

if ( -not $account)
{
    Write-Error -Message "There is no storage account called $storageAccountName ..."
    return
}

$container = Get-AzStorageContainer -Name $containerName -Context $account.Context -ErrorAction SilentlyContinue
if (-not $container)
{
    $container = New-AzStorageContainer -Name $containerName -Context $account.Context -ErrorAction Stop
}

foreach ($module in (Get-ChildItem $modulePath))
{
    $versionedFolder = $module | Get-ChildItem -Directory | Select-Object -First 1
    $archiveName = '{0}_{1}.zip' -f $module.BaseName, $versionedFolder.BaseName
    Compress-Archive -Path "$($versionedFolder.FullName)/*" -DestinationPath $archiveName
    $content = Set-AzStorageBlobContent -File $archiveName -CloudBlobContainer $container.CloudBlobContainer -Blob $archiveName -Context $account.Context -Force -ErrorAction Stop
    $token = New-AzStorageBlobSASToken -CloudBlob $content.ICloudBlob -StartTime (Get-Date) -ExpiryTime (Get-Date).AddYears(5) -Protocol HttpsOnly -Context $account.Context -Permission r -ErrorAction Stop
    $uri = 'https://{3}.blob.core.windows.net/{0}/{1}{2}' -f $containerName, $fileName, $token, $StorageAccountName

    New-AzAutomationModule -Name $module.BaseName -ContentLinkUri $uri -ResourceGroupName $resourceGroup -AutomationAccountName $automationAccountName
}
#endregion
