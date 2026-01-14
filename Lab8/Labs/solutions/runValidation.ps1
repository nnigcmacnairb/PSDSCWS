$root = Resolve-Path "$PSScriptRoot\.."
$env:PSModulePath = "$((Resolve-Path -Path (Join-Path $root output/modules) -ErrorAction Stop).Path);$env:PSModulePath"

Invoke-Pester ./build -CI