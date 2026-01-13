@{
    AllNodes  = @(
        @{
            NodeName              = 'MS'
            Role                  = 'WebServer'
            RefreshMode           = 'Push'
            ConfigurationMode     = 'ApplyAndAutoCorrect'
            CertificateThumbprint = '71C27CECB4194E821C7A4B008F77DCD9046B8C39'
            RebootNodeIfNeeded    = $true
            CertificateFile       = 'C:\PShell\Labs\DscPublicKey.cer'
            Interfaces            = @(
                @{
                    'InterfaceAlias' = 'Ethernet'
                    'IpAddress'      = '192.168.1.2/24'
                    'Gateway'        = '192.168.1.10'
                    'DnsServer'      = '192.168.1.1'
                }
            )
        }
    )

    WebServer = @{
        Features = 'Web-Server'
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
                    Credential = New-Object -TypeName PSCredential -ArgumentList 'AppPoolUser', (ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force)
                }            
            }            
            @{                
                Name         = 'Site2'
                PhysicalPath = 'C:\Site2'
                Port         = 8081
                Protocol     = 'http'
                AppPool      = @{
                    Name       = 'CustomAppPool2'
                    Credential = New-Object -TypeName PSCredential -ArgumentList 'AppPoolUser', (ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force)
                }
            }
        )
    }
}