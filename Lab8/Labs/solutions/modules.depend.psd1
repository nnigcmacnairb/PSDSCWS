@{
    PSDependOptions    = @{
        AddToPath  = $true
        Target     = 'output/modules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    NetworkingDsc        = '9.0.0'
    WebAdministrationDsc = '4.1.0'
    'Az.Accounts'        = 'latest'
    'Az.Storage'         = 'latest'
    'Az.Automation'      = 'latest'
}