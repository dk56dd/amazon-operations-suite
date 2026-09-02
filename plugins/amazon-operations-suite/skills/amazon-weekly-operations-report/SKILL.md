---
name: amazon-weekly-operations-report
description: >-
  Use this skill whenever the user asks for an Amazon weekly operations report,
  weekly seller review, week-over-week sales and advertising analysis, weekly
  inventory review, product ranking, weekly business review, or next-week
  operating plan. It is for Chinese Amazon operators and managers who provide a
  business report plus an advertising report, or have usable Lingxing MCP or
  Youmai Cloud MCP data. Verify one complete data-source path before analysis
  and stop when none is available. Produce a Chinese, table-first report with
  an execution view for operators and a decision view for management, covering
  sales, units, orders, ad spend, TACoS, ACOS, ad orders, inventory, product
  leaders and laggards, WoW causes, slow-moving and stockout exposure,
  resource decisions, owners, and next-week actions.
metadata:
  compatibility: >-
    Works with uploaded CSV, XLSX, XLS, JSON, PDF, or text reports and accessible
    Lingxing MCP or Youmai Cloud MCP tools. Use PostgreSQL by default when weekly
    history needs to be persisted; a one-off report does not require a database.
---

# Amazon Weekly Operations Report / 亚马逊运营周报分析

## 名称、视角与范围

- English name: **Amazon Weekly Operations Report**
- 中文名称：**亚马逊运营周报分析**
- 触发词：亚马逊周报、Amazon weekly report、周度经营分析、周度广告复盘、周度库存分析、下周运营计划。

两个视角必须分开输出：

| 视角 | 核心问题 | 必须产出 |
|---|---|---|
| 运营执行视角 | 本周发生了什么、为什么发生、下周具体怎么改 | 产品、广告、Listing、库存和预算动作，证据、负责人、截止时间、验收指标、停止条件 |
| 管理决策视角 | 收入、效率、库存现金和经营风险是否朝正确方向变化 | 目标差距、资源分配、产品组合优先级、升级事项和需要拍板的决策 |

只做分析和建议，不自动修改广告、价格、库存、Listing、数据库或外部系统。

## 1. 完整数据源前置条件

以下三种路径任意一条完整可用后才可分析：

| 数据源路径 | 完整条件 | 优势 | 局限 |
|---|---|---|---|
| 上传报告 | 同一站点有业务报告和广告报告，覆盖目标周 | 原始文件可审计 | 字段、日期粒度和归因口径可能不一致 |
| 领星 MCP | 实际调用成功，业务和广告两侧均返回目标周非空数据 | 适合重复获取周数据 | 受权限、账户范围、新鲜度影响 |
| 优麦云 MCP | 实际调用成功，业务和广告两侧均返回目标周非空数据 | 可利用已有经营数据 | 字段与财务口径可能不同 |

仅开启 MCP 不足以通过闸门，必须探测实际数据。无完整路径时立即停止并输出：

`无法开始周报分析：尚未发现可用的完整数据源。`

说明缺少业务报告、广告报告、领星 MCP 或优麦云 MCP，以及下一步需要提供什么。只有一份报告时，不做完整周报，不把广告数据推导成总销售或总订单。多个来源冲突时优先使用上传报告、领星 MCP、优麦云 MCP的顺序，并展示差异。

## 2. 周期与站点时间

使用站点本地时区和本地自然周，记录账户、站点、币种、时区、父子 ASIN/SKU 粒度、来源生成时间和覆盖率。时区未知时标记 `时区未确认`，不自行猜测。

| 周期 | 定义 | 用途 |
|---|---|---|
| 本周截至今日 | 本地周一至今日 | 周中运营脉搏，必须标记进行中 |
| 上周完整周 | 上一个本地周一至周日 | 默认主要复盘周期 |
| 近四个完整周 | 当前周之前的四个完整自然周 | 趋势、波动和管理判断 |
| 同比周 | 去年可比本地/ISO 周，有数据才展示 | 季节性背景，不单独作为原因 |

用户指定某周时，以指定周为主。当前周未结束时，与上周相同已过去天数比较，并同时显示总量和日均；不能将部分周直接称为完整周。不同站点、时区、币种不得直接合并。

## 3. 字段和计算口径

标准字段：`site`、`local_date`、`product_key`、`ASIN/SKU`、`sales_amount`、`currency`、`units`、`orders`、`ad_spend`、`ad_orders`、`ad_sales`、`sellable_units`、`reserved_units`、`inbound_units`、`inventory_timestamp`。可选字段：曝光、点击、会话、转化率、退货、退款、Listing 状态、补货周期、安全库存、单位成本、目标和预算。

| 指标 | 公式 | 使用规则 |
|---|---|---|
| 销售额/销量/订单数 | 业务字段按周求和 | 说明 ordered 或 shipped |
| 广告费/广告订单/广告销售额 | 广告字段按周求和 | 说明广告归因窗口和币种 |
| 广告花费占比 / TACoS | 广告费 ÷ 业务销售额 | 与 ACOS 分开 |
| 广告订单占比 | 归因广告订单 ÷ 业务订单 | 广告订单可能和业务订单重叠 |
| ACOS | 广告费 ÷ 广告销售额 | ad sales 缺失或为零时 N/A |
| 日均 | 周总量 ÷ 实际覆盖本地天数 | 用于比较部分周速度 |
| WoW |（本周 - 可比上周）÷ 可比上周 | 比率变化用百分点，不平均日百分比 |
| 可售天数 | 可售库存 ÷（近七天或本周销量 ÷ 覆盖天数） | 需求速度估算，不等于交付承诺 |

缺失、空白、零和不适用严格区分；缺失不填零。库存取最新有效本地快照，不把在途库存当成可售库存；父子行、重复导出行和重叠来源不得重复计算。币种、ordered/shipped、广告归因日期不一致时分别展示。

## 4. 运营执行视角

按证据顺序回答：

1. 销售、销量和订单的周度变化由哪些站点、产品和日期带驱动。
2. 只有存在曝光、点击、会话、转化率时，才判断流量或转化；否则写待验证假设。
3. 广告中识别扩量候选、广告依赖产品、花费无订单信号和预算迁移建议。
4. 库存中比较可售天数与补货周期加安全库存，分别展示可售、预留、在途。
5. 按周销量详细分析前五和最差五产品，突出有库存零销量商品。

每项动作包含站点/产品、证据、动作、负责人角色、截止或观察窗口、验收指标和停止条件。低排名不能单独证明产品有问题。

## 5. 管理决策视角

用表格展示：

- 销售额、销量、订单、广告费、TACoS/ACOS、库存相对目标的实际值、差距、达成率和 WoW；没有目标时标记 `未提供目标`。
- 四周趋势、销售集中度、头部产品/站点占比和广告/库存依赖。
- 有单位成本或库存价值时展示库存现金暴露；没有成本时不能用售价推算资金占用。
- 产品组合分为扩量、维持、整改、减少资源或退出候选，并写证据和不确定性。
- 广告预算、补货能力、Listing 工作、人力和新品测试之间的资源取舍。
- 需要管理层审批的事项：选项、推荐、预期收益、下行风险、负责人和决策截止时间。

没有成本、目标或完整历史时，只下趋势、效率信号、库存风险和资源优先级结论，不声称已完成利润或 ROI 判断。

## 6. 风险与升级

使用 P0 同日升级、P1 下个运营周期、P2 监控。每条风险包含等级、范围、触发证据、影响、动作、负责人、复核时间和数据限制。

| 风险 | 证据 | 处理 |
|---|---|---|
| 断货/低库存 | 可售库存为零且有需求，或可售天数低于补货周期加安全库存 | 补货/调拨、保护库存、复核广告曝光并升级到货时间 |
| 滞销 | 有库存但周销量为零，或可售天数大于 30 天且需求弱 | 降低入库，促销/组合、Listing 修复或清库存复核 |
| 广告浪费信号 | 有花费无广告订单，或效率差于用户目标 | 词/位置诊断与预算重分配；无目标只能称信号 |
| 销售波动 | 可比周销售/销量显著变化且有流量、转化、价格或库存证据 | 先验证原因，再调整预算或价格 |
| 集中度风险 | 少数产品/站点承担较大收入且存在库存、Listing 或广告依赖 | 建立备选产品、站点和产能计划 |
| 数据异常 | 缺日期、混币种、重复粒度、负数、周覆盖不全 | 仅排除受影响计算并展示缺口 |

## 7. 固定输出结构

```text
# 亚马逊运营周报分析｜站点/账户｜报告周
## 0. 管理层摘要
销售、广告效率、库存现金、最大风险、需拍板事项 3-6 条。
## 1. 数据源与口径
来源、站点、币种、时区、周区间、粒度、完整性、优势、局限表。
## 2. 核心经营指标
本周截至今日、上周完整周、近四个完整周、同比周；销售额、销量、订单、日均、广告费、TACoS、广告订单、广告订单占比、广告销售额、ACOS、库存、可售天数、WoW。
## 3. 运营执行复盘
销售、广告、库存、产品：事实、原因、动作、验收指标。
## 4. 销量前五与最差五
周销量排名和逐产品事实-判断-动作表。
## 5. 管理层经营判断
目标达成、趋势、集中度、现金/库存暴露、产品组合、资源分配、拍板事项。
## 6. 风险与升级清单
P级、风险、范围、证据、影响、动作、负责人、时间、数据限制。
## 7. 下周计划
按 P0/P1/P2 排序，给动作、负责人、验收指标和停止条件。
## 8. 数据质量与待补字段
只列影响结论的缺口。
```

资源竞争时，补充 `资源排序的优势与局限` 表，说明排序为何保护收入、现金或服务水平，以及缺少目标、成本、归因或历史数据时的局限。
