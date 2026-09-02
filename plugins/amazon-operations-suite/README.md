# Amazon Operations Suite

开发者：不见山谷  
网站：[https://ainexa.us/](https://ainexa.us/)  
版本：1.1.0

本插件面向 Codex 与 WorkBuddy，一次安装后提供 32 个可独立调用的亚马逊运营技能，涵盖市场研究、竞品、评论痛点、利润成本、Listing、关键词、广告、供应链、补货、退货以及日报、周报和月报。

## Codex 调用示例

```text
$amazon-listing-alexa-writer
美国站，产品是……，请根据附件中的真实规格编写标题和五点描述。
```

## WorkBuddy 调用示例

```text
/amazon-weekly-operations-report
根据上传的数据生成美国站上周运营周报，并与此前四周比较。
```

完整说明见仓库根目录的 `docs/32技能新手使用手册.md`。

## 数据连接

本插件不内置第三方账户、密钥或登录状态。需要经营数据时可以上传报告；外部 MCP 数据源需要单独配置。未发现完整数据源时，技能会明确提示缺少的资料，不会编造数字。
