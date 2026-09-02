$ErrorActionPreference = 'Stop'

$pluginName = 'amazon-operations-suite'
$marketplaceFile = Join-Path $PSScriptRoot '.agents\plugins\marketplace.json'

if (-not (Test-Path -LiteralPath $marketplaceFile)) {
    throw "Marketplace manifest not found: $marketplaceFile"
}

$marketplace = Get-Content -LiteralPath $marketplaceFile -Raw -Encoding UTF8 | ConvertFrom-Json
$marketplaceName = $marketplace.name

Write-Host "Registering local marketplace: $marketplaceName"
codex plugin marketplace add $PSScriptRoot --json
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to register the local marketplace.'
}

Write-Host "Installing plugin: $pluginName@$marketplaceName"
codex plugin add "$pluginName@$marketplaceName" --json
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to install the plugin.'
}

Write-Host 'Installation completed. Start a new Codex task before invoking the skills.'
