$ErrorActionPreference = 'Stop'

$pluginName = 'amazon-operations-suite'
$marketplaceFile = Join-Path $PSScriptRoot '.codebuddy-plugin\marketplace.json'

if (-not (Get-Command codebuddy -ErrorAction SilentlyContinue)) {
    throw '未发现 codebuddy 命令。请先安装或更新 WorkBuddy/CodeBuddy CLI。'
}
if (-not (Test-Path -LiteralPath $marketplaceFile)) {
    throw "WorkBuddy marketplace manifest not found: $marketplaceFile"
}

$marketplace = Get-Content -LiteralPath $marketplaceFile -Raw -Encoding UTF8 | ConvertFrom-Json
$marketplaceName = $marketplace.name

Write-Host "正在注册 WorkBuddy 插件市场：$marketplaceName"
codebuddy plugin marketplace add $PSScriptRoot
if ($LASTEXITCODE -ne 0) {
    throw '注册 WorkBuddy 插件市场失败。'
}

Write-Host "正在安装 WorkBuddy 插件：$pluginName@$marketplaceName"
codebuddy plugin install "$pluginName@$marketplaceName" --scope user
if ($LASTEXITCODE -ne 0) {
    throw '安装 WorkBuddy 插件失败。'
}

Write-Host '安装完成。请在 WorkBuddy 中执行 /reload-plugins，然后通过 /skills 检查32个技能。'
