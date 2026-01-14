BeforeDiscovery {
    $configData = Import-LocalizedData -BaseDirectory C:\PShell\Labs -FileName configurationdata.psd1 -SupportedCommand New-Object,ConvertTo-SecureString
}

Describe ConfigurationData {
    It 'IP <IpAddress> is a valid IP address' -TestCases $configData.AllNodes.Interfaces {
        ($IpAddress -replace '/\d*') -as [ipaddress] | Should -Not -BeNullOrEmpty
    }
}