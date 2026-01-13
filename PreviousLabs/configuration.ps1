
Install-PackageProvider Nuget -Force
Set-psrepository -Name PSGallery -InstallationPolicy Trusted
Install-Module NetworkingDsc -Force -Scope Allusers
Install-Module xWebAdministration -force -scope allusers


Invoke-Command -ComputerName MS -ScriptBlock {
    Install-PackageProvider NuGet -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module xWebAdministration -Force -Scope AllUsers
    Install-Module NetworkingDsc     -Force -Scope AllUsers
}
  

configuration ContosoWebServer {
        param(
                    [string[]]$NodeName = 'MS'
        )

            Import-DscResource -ModuleName PSDesiredStateConfiguration
            Import-DscResource -ModuleName NetworkingDsc
            Import-DscResource -modulename xWebAdministration

                    Node $NodeName {
                        # Install IIS
                        WindowsFeature IIS {Name='Web-Server'; Ensure='Present';IncludeAllSubFeature = $true}
                        WindowsFeature IISMgmt {Name='Web-Mgmt-Tools';Ensure='Present';IncludeAllSubFeature = $true;DependsOn = '[WindowsFeature]IIS'}

                        # Windows activation service required for iis
                        WindowsFeature WAS {
                            Name = 'WAS'
                            Ensure = 'Present'
                            DependsOn = '[WindowsFeature]IIS'
                            IncludeAllSubFeature = $true
                        }

                        xWebsite Site1 {
                            Name = 'Site1'
                            Ensure = 'Present'
                            PhysicalPath = join-path 'c:\web' 'Site1'
                            State = 'Started'
                            BindingInfo = @(              
                                MSFT_xWebBindingInformation {
                                    Protocol  = 'HTTP'
                                    Port      = 8081
                                    IPAddress = '*'
                                })
                            DependsOn = @('[WindowsFeature]IIS','[File]Webroot1')

                            }

                            xWebsite Site2 {
                                Name = 'Site2'
                                Ensure = 'Present'
                                PhysicalPath = join-path 'c:\web' 'Site2'
                                State = 'Started'
                                BindingInfo = @(              
                                    MSFT_xWebBindingInformation {
                                        Protocol  = 'HTTP'
                                        Port      = 8181
                                        IPAddress = '*'
                                    })
                                DependsOn = @('[WindowsFeature]IIS','[File]Webroot1')
    
                                }                            


                        ## Folders
                        File Webroot1 {
                            Type = 'Directory'
                            Ensure = 'Present'
                            SourcePath = '\\Client01\PSHELL\Site1'
                            DestinationPath = Join-Path 'c:\web\' 'Site1'
                            Recurse = $true
                            DependsOn = '[ipaddress]SetIpAddress'
                        }
                        File Webroot2 {
                            Type = 'Directory'
                            Ensure = 'Present'
                            SourcePath = '\\Client01\PSHELL\Site2'
                            DestinationPath = Join-Path 'c:\web\' 'Site2'
                            Recurse = $true
                            DependsOn = '[ipaddress]SetIpAddress'
                        }


                        # Configure Network Adapter
                        IPAddress SetIPAddress {
                            InterfaceAlias ='Ethernet'
                            Addressfamily = 'IPv4'
                            IPAddress = '192.168.1.2'
                            KeepExistingAddress = $False
                        }

                        DefaultGatewayAddress setGateway {
                            InterfaceAlias =  'Ethernet'
                            AddressFamily =  'IPv4'
                            Address = '192.168.1.10'
                            DependsOn = '[IPAddress]SetIpAddress'
                        }

                        DnsServerAddress setDns {
                            InterfaceAlias = 'Ethernet'
                            AddressFamily =  'IPv4'
                            Address = '192.168.1.1'
                            DependsOn = '[IPAddress]SetIPAddress'
                        }
                    }
                }

                # Generate MOF
                ContosoWebServer -OutputPath 'C:\DSC\ContosoWebServer'