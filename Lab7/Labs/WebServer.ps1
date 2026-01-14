$configData = Import-LocalizedData -BaseDirectory C:\PShell\Labs -FileName configurationdata.psd1 -SupportedCommand New-Object,ConvertTo-SecureString

configuration WebServer
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WebAdministrationDsc
    Import-DscResource -ModuleName NetworkingDsc

    node $AllNodes.Where( { $_.Role -eq 'WebServer' }).NodeName
    {
        $nodeConfig = $configurationData[$Node.Role]

        # Copy content
        $dependencies = @()
        foreach ($folder in $nodeConfig.Folders)
        {
            $resourceName = $folder.Source -replace '\W'
            $dependencies += "[File]$resourceName"
            File $resourceName
            {
                SourcePath      = $folder.Source
                DestinationPath = $folder.Destination
                Type            = 'Directory'
                Ensure          = 'Present'
            }
        }

        # Install features
        foreach ($feature in $nodeConfig.Features)
        {
            $dependencies += "[WindowsFeature]$feature"
            WindowsFeature $feature
            {
                Name   = $feature
                Ensure = 'Present'
            }
        }

        foreach ($interface in $node.Interfaces)
        {
            NetIPInterface "DisableDhcp_$($interface.InterfaceAlias)"
            {
                InterfaceAlias = $interface.InterfaceAlias
                AddressFamily  = 'IPv4'
                Dhcp           = 'Disabled'
            }

            IPAddress "NetworkIp_$($interface.InterfaceAlias)"
            {
                IPAddress      = $interface.IpAddress
                AddressFamily  = 'IPv4'
                InterfaceAlias = $interface.InterfaceAlias
            }

            DefaultGatewayAddress "DefaultGateway_$($interface.InterfaceAlias)"
            {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $interface.InterfaceAlias
                Address        = $interface.Gateway
            }
        }

        # Create web sites
        foreach ($site in $nodeConfig.WebSites)
        {
            WebAppPool $site.AppPool.Name
            {
                Name = $site.AppPool.Name
                Credential = Get-AutomationPSCredential -Name "$($site.AppPool.CredentialName)" -ResourceGroupName $R$ResourceGroupName 
            }
            WebSite $site.Name
            {
                Name            = $site.Name
                PhysicalPath    = $site.PhysicalPath
                ApplicationPool = $($site.AppPool.Name)
                BindingInfo = DSC_WebBindingInformation {
                    Port = $site.Port
                    Protocol =  $site.Protocol
                }
                DependsOn       = $dependencies, "[WebAppPool]$($site.AppPool.Name)"
            }
        }
    }
}

WebServer -ConfigurationData $configData
