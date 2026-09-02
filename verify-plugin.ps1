$ErrorActionPreference = 'Stop'

$expectedSkills = 32
$pluginName = 'amazon-operations-suite'
$marketplaceName = 'ainexa-amazon-tools'
$marketplaceFile = Join-Path $PSScriptRoot '.agents\plugins\marketplace.json'
$workBuddyMarketplaceFile = Join-Path $PSScriptRoot '.codebuddy-plugin\marketplace.json'
$pluginRoot = Join-Path $PSScriptRoot "plugins\$pluginName"
$manifestFile = Join-Path $pluginRoot '.codex-plugin\plugin.json'
$workBuddyManifestFile = Join-Path $pluginRoot '.codebuddy-plugin\plugin.json'
$skillsRoot = Join-Path $pluginRoot 'skills'

$marketplace = Get-Content -LiteralPath $marketplaceFile -Raw -Encoding UTF8 | ConvertFrom-Json
$workBuddyMarketplace = Get-Content -LiteralPath $workBuddyMarketplaceFile -Raw -Encoding UTF8 | ConvertFrom-Json
$manifest = Get-Content -LiteralPath $manifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$workBuddyManifest = Get-Content -LiteralPath $workBuddyManifestFile -Raw -Encoding UTF8 | ConvertFrom-Json
$skillDirectories = @(Get-ChildItem -LiteralPath $skillsRoot -Directory)
$missingSkillFiles = @($skillDirectories | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md'))
})

if ($marketplace.name -ne $marketplaceName) {
    throw "Unexpected marketplace name: $($marketplace.name)"
}
if ($manifest.name -ne $pluginName) {
    throw "Unexpected plugin name: $($manifest.name)"
}
if ($workBuddyMarketplace.name -ne $marketplaceName) {
    throw "Unexpected WorkBuddy marketplace name: $($workBuddyMarketplace.name)"
}
if ($workBuddyManifest.name -ne $pluginName) {
    throw "Unexpected WorkBuddy plugin name: $($workBuddyManifest.name)"
}
if ($workBuddyManifest.version -ne $manifest.version) {
    throw "Platform manifest versions do not match."
}
if ($skillDirectories.Count -ne $expectedSkills) {
    throw "Expected $expectedSkills skills, found $($skillDirectories.Count)."
}
if ($missingSkillFiles.Count -gt 0) {
    throw "Missing SKILL.md in: $($missingSkillFiles.Name -join ', ')"
}

$cacheRoot = Join-Path $env:USERPROFILE ".codex\plugins\cache\$marketplaceName\$pluginName\$($manifest.version)"

[pscustomobject]@{
    Marketplace = $marketplace.name
    Plugin = $manifest.name
    Version = $manifest.version
    Skills = $skillDirectories.Count
    CodexManifest = $true
    WorkBuddyManifest = $true
    SourceValid = $true
    InstalledCacheExists = Test-Path -LiteralPath $cacheRoot
}
