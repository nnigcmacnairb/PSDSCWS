configuration LocalRegistry
{
    Import-DscResource -ModuleName PSDSCResources

    Registry Test
    {
        Key = 'HKLM:\SOFTWARE\DscOnAzure'
        ValueName = 'DoesItStillWork'
        ValueData = 'YesItDoes'
    }
}

LocalRegistry -OutputPath C:\PShell\Labs\LocalRegistry
