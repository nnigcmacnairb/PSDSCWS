
$root = Resolve-Path "$PSScriptRoot\.."
$env:PSModulePath = "$((Resolve-Path -Path (Join-Path $root output/modules) -ErrorAction Stop).Path);$env:PSModulePath"

& (Join-Path $root configuration.ps1)