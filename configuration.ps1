
configuration ContosoWebServer {
        param(
                    [string[]]$NodeName = 'localhost'
        )

            Import-DscResource -ModuleName PSDesiredStateConfiguration
                # Add other modules like xWebAdministration if needed

                    Node $NodeName {
                                # Your DSC resources go here
                    }
                }

                # Generate MOF
                ContosoWebServer -OutputPath 'C:\DSC\ContosoWebServer'
