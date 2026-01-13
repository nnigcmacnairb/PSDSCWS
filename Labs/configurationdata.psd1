@{
    AllNodes  = @(
        @{
            NodeName   = 'MS'
            Role       = 'WebServer'
            Interfaces = @(
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

        # Below a snippet  showing what the changes to the configurationdata.psd1 could look like.
        WebSites = @(
            @{
                Name         = 'Site1'
                PhysicalPath = 'C:\Site1'
                AppPool      = @{
                    # Name must be unique
                    Name = 'CustomAppPool1'
                    # WARNING - The credentials shouldn't be in Plaintext in the Configuration               
                    Credential = New-Object -TypeName PSCredential -ArgumentList 'AppPoolUser',(ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force)
                }
                Port         = 8080
                Protocol     = 'http' 
            }            
            @{                
                Name         = 'Site2'
                PhysicalPath = 'C:\Site2'
                AppPool      = @{
                    Name = 'CustomAppPool2'
                    # Alternative way to create a PSCredential Object
                    Credential = New-Object -TypeName PSCredential -ArgumentList 'AppPoolUser',(ConvertTo-SecureString -String 'Pa$$w0rd' -AsPlainText -Force)
            }
                Port         = 8081
                Protocol     = 'http' 
            }
        ) 
    }
}