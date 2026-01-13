configuration WebServer
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WebAdministrationDsc
    Import-DscResource -ModuleName NetworkingDsc

    node $AllNodes.NodeName
    {
        if ($Node.Role -eq 'WebServer') {
            #just the web server configuration items
            
            foreach ($site in $ConfigurationData.Webserver.Sites)
            {
                $fileResourceName = "[File]$site"

                WebSite $site
                {
                    Name         = $site
                    PhysicalPath = "C:\$site"
                    BindingInfo = DSC_WebBindingInformation {
                        Port = 8080
                        Protocol =  'http'
                    }
                    DependsOn    = $fileResourceName
                }

                File $site
                {
                    SourcePath      = "\\Client01\PShell\$site"
                    DestinationPath = "C:\$site"
                    Type            = 'Directory'
                    Ensure          = 'Present'
                }


                

            }
    
            foreach ($windowsFeature in $ConfigurationData.WebServer.WindowsFeatures) {
                WindowsFeature $windowsFeature {
                    Name   = $windowsFeature
                    Ensure = 'Present'
                }
            }    
        }
        elseif ($Node.Role -eq 'FileServer') {
            File TestFile1 {
                DestinationPath = 'C:\TestFile1.txt'
                Type            = 'File'
                Ensure          = 'Present'
                Contents        = '123'
            }
        }
        
        

        NetIPInterface "DisableDhcp_Ethernet"
        {
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            Dhcp           = 'Disabled'
        }

        IPAddress "NetworkIp_Ethernet"
        {
            IPAddress      = $Node.IPAddress
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet'
        }

        DefaultGatewayAddress "DefaultGateway_Ethernet"
        {
            AddressFamily  = $configurationData.Baseline.AddressFamily
            InterfaceAlias = $configurationData.Baseline.InterfaceAlias
            Address        = $configurationData.Baseline.DefaultGateway
        }
    }
}

WebServer -ConfigurationData .\ConfigurationData.psd1