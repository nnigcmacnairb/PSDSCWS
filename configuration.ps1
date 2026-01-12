
configuration ContosoWebServer {
        param(
                    [string[]]$NodeName = 'MS'
        )

            Import-DscResource -ModuleName PSDesiredStateConfiguration
            Import-DscResource -ModuleName NetworkingDsc
                # Add other modules like xWebAdministration if needed

                    Node $NodeName {
                        # Install IIS
                        WindowsFeature IIS {Name='Web-Server'; Ensure='Present'}

                        # Configure Network Adapter
                        IPAddress SetIPAddress {
                            InterfaceAlias ='Ethernet'
                            Addressfamily = 'IPv4'
                            IPAddress = 192.168.1.2/24
                            KeepExistingAddress = $False
                        }

                        DefaultGatewayAddress setGateway {
                            InterfaceAlias =  'Ethernet'
                            AddressFamily =  'IPv4'
                            Address = 192.168.1.10
                            DependsOn = '[IPAddress]SetIpAddress'
                        }

                        DnsServerAddress setDns {
                            InterfaceAlias = 'Ethernet'
                            AddressFamily =  'IPv4'
                            Address = 192.168.1.1
                            DependsOn = '[IPAddress]SetIPAddress'
                        }
                    }
                }

                # Generate MOF
                ContosoWebServer -OutputPath 'C:\DSC\ContosoWebServer'