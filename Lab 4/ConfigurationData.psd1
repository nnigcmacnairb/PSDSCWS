@{
    AllNodes = @(
        @{
            NodeName = 'MS'
            IPAddress = '192.168.1.2/24'
            Role = 'WebServer'
        }
        @{
            NodeName = 'MS1'
            IPAddress = '192.168.1.3/24'
            Role = 'FileServer'
        }        
    )
    WebServer = @{
        Sites = 'Site1', 'Site2'
        WindowsFeatures = 'Web-Server'
    }
    Baseline = @{
        DefaultGateway = '192.168.1.10'
        AddressFamily = 'IPv4'
        InterfaceAlias = 'Ethernet'
    }
}
