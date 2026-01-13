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
                Credential = $site.AppPool.Credential
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

[DscLocalConfigurationManager()]
configuration LCMConfig
{
    node $AllNodes.Where({$_.Role -eq 'WebServer'}).NodeName
    {
        Settings
        {
            # Default is Push - Possible: Disabled, Push, Pull
            RefreshMode = $node.RefreshMode
            # Default is ApplyAndMonitor - Possible: MonitorOnly,ApplyOnly,ApplyAndMonitor or ApplyAndAutoCorrect
            ConfigurationMode =  $Node.ConfigurationMode
            # This is the thumbprint of the certificate to be used to decrypt credentials in the MOF
            CertificateId = $node.CertificateThumbprint
            # Default is False - This will allow the LCM to reboot the node it a resource requires it.
            RebootNodeIfNeeded = $node.RebootNodeIfNeeded  
        }
    }
}

LcmConfig -COnfigurationData $configData
