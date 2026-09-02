# Amazon Operations Suite

Codex + WorkBuddy 双平台亚马逊运营插件，一次安装即可使用 32 个中文技能。

- 开发者：不见山谷
- 网站：[https://ainexa.us/](https://ainexa.us/)
- 当前版本：1.1.0
- 插件名：`amazon-operations-suite`
- 插件市场：`ainexa-amazon-tools`
- GitHub：[dk56dd/amazon-operations-suite](https://github.com/dk56dd/amazon-operations-suite)

## 能做什么

覆盖市场研究、评论痛点、竞品、差异化、利润成本、FBA 包装、合规、供应链、新品预算、销售计划、发补货、ABA、Listing、关键词、SP 广告、退货以及运营日报、周报和月报。

完整的 32 项用途、准备数据、调用示例和避坑提示见：[32 技能新手使用手册](docs/32技能新手使用手册.md)。

## 安装到 Codex

### 从 GitHub 安装

```powershell
codex plugin marketplace add dk56dd/amazon-operations-suite --ref main --json
codex plugin add amazon-operations-suite@ainexa-amazon-tools --json
```

安装完成后新建一个 Codex 任务，再用 `$技能调用名` 调用：

```text
$amazon-daily-operations-report 根据我上传的业务和广告报表生成今天的运营日报。
```

### 从下载的压缩包安装

解压后在 PowerShell 中进入目录并运行：

```powershell
.\install-plugin.ps1
```

## 安装到 WorkBuddy

### 在 WorkBuddy/CodeBuddy 对话中安装

```text
/plugin marketplace add dk56dd/amazon-operations-suite
/plugin install amazon-operations-suite@ainexa-amazon-tools
/reload-plugins
/skills
```

### 用 CodeBuddy CLI 安装

```powershell
codebuddy plugin marketplace add dk56dd/amazon-operations-suite
codebuddy plugin install amazon-operations-suite@ainexa-amazon-tools --scope user
```

也可以下载并解压插件包后运行：

```powershell
.\install-workbuddy.ps1
```

WorkBuddy 中可以通过自然语言自动匹配，也可以手动输入 `/技能调用名`：

```text
/amazon-daily-operations-report 根据附件生成运营日报。
```

## 公开安装

GitHub 仓库已经设为 Public。任何人都可以查看、克隆并按上面的命令安装，无需成为仓库协作者。需要离线分发时，也可以直接使用 Release 或本地提供的 ZIP 安装包。

## 数据与权限说明

- 插件内置的是 32 套技能工作流，不内置店铺数据、第三方账号、Cookie、Token 或密钥。
- 业务、广告、库存、成本等数据可以通过附件提供，或由你自行配置已授权的数据连接。
- 依赖 Sorftime、SellerSprite 或 SIF 的技能在数据源未连接时会明确提示，不会伪造查询结果。
- 技能默认进行读取、分析和内容生成，不会自动改广告、改链接、创建货件或下采购单。

## 目录结构

```text
.
├── .agents/plugins/marketplace.json               # Codex 市场清单
├── .codebuddy-plugin/marketplace.json              # WorkBuddy 市场清单
├── docs/32技能新手使用手册.md
├── plugins/amazon-operations-suite/
│   ├── .codex-plugin/plugin.json                   # Codex 插件清单
│   ├── .codebuddy-plugin/plugin.json               # WorkBuddy 插件清单
│   └── skills/<skill-name>/SKILL.md                 # 32 个共享技能
├── install-plugin.ps1
├── install-workbuddy.ps1
└── verify-plugin.ps1
```

## 本地验证

```powershell
.\verify-plugin.ps1
```

验证脚本会检查两个平台的市场清单、两个插件清单、版本一致性以及 32 个技能目录。WorkBuddy/CodeBuddy 未安装在本机时，仍可完成静态结构验证；实际安装测试需要在已安装 WorkBuddy 的环境中进行。

## 更新记录

见 [CHANGELOG.md](CHANGELOG.md)。
