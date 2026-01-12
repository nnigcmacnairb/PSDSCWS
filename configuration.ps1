
configuration ContosoWebServer {
        param(
                    [string[]]$NodeName = 'MS'
        )

            Import-DscResource -ModuleName PSDesiredStateConfiguration
                # Add other modules like xWebAdministration if needed

                    Node $NodeName {
                        # Install IIS
                        WindowsFeature IIS {Name='Web-Server'; Ensure='Present'}

                    }
                }

                # Generate MOF
                ContosoWebServer -OutputPath 'C:\DSC\ContosoWebServer'
