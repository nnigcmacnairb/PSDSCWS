@{
    AllNodes  = @(
        @{
            NodeName              = 'MS'
            Role                  = 'WebServer'
            RefreshMode           = 'Push'
            ConfigurationMode     = 'ApplyAndAutoCorrect'
            CertificateThumbprint = '71C27CECB4194E821C7A4B008F77DCD9046B8C39'
            RebootNodeIfNeeded    = $true
            # CertificateThumbprint     = '71C27CECB4194E821C7A4B008F77DCD9046B8C39'
            # CertificateFile           = 'C:\PShell\Labs\DscPublicKey.cer
            # Required to allow DSC to include credentials in MOF content
            PSDscAllowPlainTextPassword = $true
            Interfaces            = @(
                @{
                    'InterfaceAlias' = 'Ethernet'
                    'IpAddress'      = '192.168.1.2/24'
                    'Gateway'        = '192.168.1.10'
                    'DnsServer'      = '192.168.1.1'
                }
                #@{
                #    'InterfaceAlias' = 'Ethernet2'
                #    'IpAddress'      = '192.168.1.999/24'
                #    'Gateway'        = '192.168.1.10'
                #    'DnsServer'      = '192.168.1.1'
                #}
            )
        }
    )

    WebServer = @{
        Features = 'Web-Server', 'Web-Asp-Net45', 'Web-Dyn-Compression'
        Folders  = @(
            @{
                Source      = '\\Client01\PShell\Site1'
                Destination = 'C:\Site1'
            }
            @{
                Source      = '\\Client01\PShell\Site2'
                Destination = 'C:\Site2'
            }
        )
        WebSites = @(
            @{
                Name         = 'Site1'
                PhysicalPath = 'C:\Site1'
                Port         = 8080
                Protocol     = 'http'
                AppPool      = @{
                    Name       = 'CustomAppPool1'           
                    Credential = 'CustomAppPool1'           
                }            
            }            
            @{                
                Name         = 'Site2'
                PhysicalPath = 'C:\Site2'
                Port         = 8081
                Protocol     = 'http'
                AppPool      = @{
                    Name       = 'CustomAppPool2'
                    Credential = 'CustomAppPool2'           
                }
            }
        )
    }
}