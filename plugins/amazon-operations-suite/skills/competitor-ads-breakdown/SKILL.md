---
name: competitor-ads-breakdown
description: 拆解亚马逊竞品广告结构、投放路径、关键词打法和可复制攻击点。Use when the user provides competitor ASINs, keywords, category context, screenshots, or asks how a competitor advertises, where traffic comes from, what campaigns/keywords/placements may be driving sales, or how to counter a competitor using SIF MCP, 卖家精灵/SellerSprite MCP, or web fallback.
---

# 拆解竞品广告

## 核心原则

先判断 MCP 接入，再拆广告。没有 SIF MCP 或卖家精灵 MCP 时，不要输出确定的广告结构、关键词贡献或预算判断。

本 Skill 用于拆解亚马逊竞品广告，包括 ASIN 广告结构、关键词流量、Campaign/AdGroup/Targeting 线索、广告位倾向、自然与广告流量关系、可复制打法和反制策略。

## 第 0 步：MCP 接入检查

开始前必须判断当前 agent 是否能调用：

- `SIF MCP` / `sif mcp`
- `卖家精灵 MCP` / `sellersprite mcp`

检查方式：

- 若当前会话已暴露 MCP 工具，直接检查工具名称和能力。
- 若支持 `tool_search`，优先搜索 `sif`、`sellersprite`、`卖家精灵`。
- 不要编造未暴露的 MCP；只能调用真实可用工具。

按结果分流：

- 两者都不可用：先告诉用户“当前未检测到 SIF / 卖家精灵 MCP 接入，只能用联网公开信息和 Amazon 前台可见结果做广告打法推断，关键词贡献、Campaign 结构、预算和 ACOS 会有明显误差”。然后走联网低置信分析。
- 只有 SIF 可用：以 SIF 广告结构和流量趋势为主，缺少销量/评论/BSR 验证时标注缺口。
- 只有卖家精灵可用：以销量、排名、评论、趋势验证竞品强弱，广告结构只能推断，不要冒充 Campaign 明细。
- 两者都可用：先用 SIF 拆广告，再用卖家精灵验证商业结果。

## 第 1 步：识别输入

根据用户输入选择路径：

- 单个竞品 ASIN：做广告结构、关键词、流量与销售结果拆解。
- 多个竞品 ASIN：比较广告打法差异，找可复制与不可打的点。
- 关键词：看该词下竞品广告位、头部 ASIN 和进入难度。
- 类目：先抽样头部竞品，再拆广告共性。

缺少 ASIN 时，先问用户补充；若用户只有关键词或类目，就先基于关键词/类目识别竞品池。

## 第 2 步：SIF MCP 广告拆解链路

SIF MCP 可用时，按以下顺序调用，不要跳步直接下结论：

1. `ads_get_asin_ad_structure`：先看 ASIN 广告规模、广告类型、Campaign/AdGroup/Keyword 结构。
2. `ads_get_asin_ad_traffic_trend`：看广告流量变化与波动时间点。
3. `ads_get_asin_campaign_changes`：定位预算、竞价、结构调整是否驱动流量变化。
4. `ads_get_asin_campaign_contribution_overview`：判断主要 Campaign 贡献。
5. `ads_get_campaign_traffic_trend`：下钻关键 Campaign 的流量趋势。
6. `ads_get_campaign_structure`：看 Campaign 内 AdGroup、匹配类型、Targeting 组织方式。
7. `ads_get_campaign_contribution_breakdown`：拆贡献来源，识别核心广告词/商品投放。
8. `ads_get_ad_group_traffic_trend` 与 `ads_get_ad_group_keyword_breakdown`：下钻到 AdGroup 和关键词。

分析时必须区分：

- 广告结构观察：工具看到的 Campaign/AdGroup/Keyword。
- 广告效果推断：由流量趋势、贡献占比、排名和销售表现推断。
- 运营动作建议：agent 基于证据给出的打法，不是工具原始输出。

## 第 3 步：卖家精灵 MCP 验证链路

卖家精灵 MCP 可用时，优先验证：

- ASIN 销量、销售额、价格、BSR、类目排名。
- 销量趋势、排名趋势、价格与 Coupon 变化。
- 评论数量、评分、Review 增速和差评主题。
- 竞品上架时间、品牌、变体、类目节点。

用途：

- 判断广告是否真正带来商业结果。
- 判断竞品是否靠广告硬推、自然流量沉淀，还是促销/价格驱动。
- 判断是否值得复制其广告结构，或只借鉴部分关键词。

## 第 4 步：无 MCP 的联网兜底

无 MCP 时必须先输出风险提示：

```text
当前未检测到 SIF / 卖家精灵 MCP 接入。下面只能用联网公开信息和 Amazon 前台可见结果做广告打法推断，关键词贡献、Campaign 结构、预算和 ACOS 会有明显误差，结论只能作为初筛参考。
```

可用公开信号：

- Amazon 搜索结果页的 Sponsored 位置、竞品出现频次、标题卖点。
- 商品详情页的 Sponsored related products、Frequently bought、类目排名、价格、Coupon。
- 公开评论、QA、品牌站、社媒和测评内容。
- 搜索多个核心词，记录竞品广告出现位置和频率。

禁区：

- 不要编造 Campaign 名称、预算、ACOS、CPC。
- 不要把一次搜索看到的 Sponsored 位置当成稳定广告位。
- 不要断言关键词贡献比例，只能说“可能重点投放”。

## 第 5 步：拆解维度

每次输出至少覆盖：

1. 广告目标：打排名、打新品、守品牌词、抢竞品词、清库存、推变体。
2. 广告结构：Campaign 层级、AdGroup 组织、匹配类型、商品投放与关键词投放比例。
3. 关键词打法：大词、长尾词、竞品词、场景词、属性词、品牌词。
4. 广告位倾向：Top of Search、商品页、Rest of Search、类目/竞品页。
5. 广告与自然关系：广告是否在托排名、自然是否承接。
6. 商业结果：销量、排名、评论、价格、转化基础是否支撑广告。
7. 可复制动作：可以学什么、不能学什么、如何反制。

## 第 6 步：输出格式

第一句直接给判断：

```text
这个竞品的广告打法主要是【关键词强推 / 商品投放截流 / 品牌防守 / 低价促销承接 / 混合打法】，我们可复制的是……，不建议复制的是……
```

推荐结构：

```markdown
这个竞品的广告打法主要是……，可复制点是……，最大风险是……

**证据**
- 广告结构：……
- 关键词/Targeting：……
- 广告位：……
- 销量与排名验证：……
- 评论与转化基础：……

**打法拆解**
- 它怎么拿流量：……
- 它怎么承接转化：……
- 它可能怎么调预算/竞价：……

**我们怎么打**
- 可复制：……
- 反制：……
- 避开：……

**置信度**
- 数据来源：SIF / 卖家精灵 / 联网公开信息
- 数据缺口：……
- 把握程度：高 / 中 / 低
```

## 第 7 步：结论口径

使用明确结论：

- `可复制`：结构清晰、关键词相关、转化基础可追、成本可承受。
- `只可局部借鉴`：竞品有品牌/评论/价格优势，不能照搬。
- `不建议正面打`：头部评论壁垒强、广告强度高、利润承接不足。
- `适合截流`：竞品有流量但差评明显，可通过商品投放或痛点词切入。

必须解释“为什么不是另一个结论”。

## 质量红线

- 不要把工具字段原样堆给用户，要转成广告判断。
- 不要在无 MCP 时输出精确广告结构。
- 不要建议违规刷评、恶意点击、跟卖、侵权、黑帽广告玩法。
- 不要只说“加大广告”，必须说明词、广告位、预算阶段和风险边界。
