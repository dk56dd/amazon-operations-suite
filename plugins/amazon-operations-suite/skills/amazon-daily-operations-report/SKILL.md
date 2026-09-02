---
name: amazon-daily-operations-report
description: >-
  Use this skill whenever the user asks for an Amazon seller daily report, store
  operating dashboard, daily business and advertising summary, sales and
  inventory review, top or bottom ASIN analysis, slow-moving risk, stockout risk,
  or a daily operating action list. It is especially intended for Chinese
  Amazon operators who provide a business report plus an advertising report, or
  who have usable Lingxing MCP or Youmai Cloud MCP data. First verify that one
  complete data-source path is actually available; stop and request the missing
  source when it is not. Produce a Chinese, table-first report for Today,
  Yesterday, the latest 3 local dates, and the latest 7 local dates, covering
  sales amount, units, orders, ad spend, ad-spend share, ad orders, ad-order
  share, inventory, product leaders and laggards, slow-moving risk, stockout
  risk, and prioritized actions.
metadata:
  compatibility: >-
    Works with uploaded CSV, XLSX, XLS, JSON, PDF, or text reports and with
    accessible Lingxing MCP or Youmai Cloud MCP tools. Use PostgreSQL as the
    default persistence layer if a reusable data store is needed; do not require
    a database for a one-off report.
---

# Amazon Daily Operations Report / 亚马逊运营日报分析

## Names and scope

- English name: **Amazon Daily Operations Report**
- 中文名称：**亚马逊运营日报分析**
- Common triggers: 亚马逊运营日报、店铺日报、Amazon daily report、销售广告日报、库存风险日报、ASIN 销量排名、滞销/断货分析。

Use this skill to analyze data and recommend actions. Do not change campaigns,
prices, inventory, listings, databases, or external systems unless the user
explicitly asks for a separate implementation action.

## 1. Gate the analysis before doing any calculations

Treat the following as three alternative complete source paths:

| Source path | What must be available | 优势 | 劣势 |
|---|---|---|---|
| Uploaded reports | Both a business report and an advertising report, covering the same site and usable date range | Can be audited from the original files and does not depend on a live connector | File formats, date columns, and metric names may differ |
| Lingxing MCP | The connector is enabled, calls succeed, and both business and advertising data can be retrieved | Can obtain the requested date windows directly and may include richer inventory fields | Depends on connector permissions, account scope, and API freshness |
| Youmai Cloud MCP | The connector is enabled, calls succeed, and both business and advertising data can be retrieved | Useful when the operator's daily data already lives in Youmai Cloud | Tool schemas and attribution definitions may differ from reports |

The gate passes only when one complete path is available. “MCP is enabled” is
not evidence that data is retrievable: perform a harmless connection or data
discovery call and verify a non-empty result for the requested site and date
range. If no path passes, stop before analysis and respond in Chinese with:

1. `无法开始日报分析：尚未发现可用的完整数据源。`
2. The missing item: business report, advertising report, Lingxing MCP access,
   or Youmai Cloud MCP access.
3. Exactly what the user can provide next. Do not manufacture numbers or give
   speculative product conclusions.

If only a business report or only an advertising report is provided, the gate
does not pass for the full report. If a connector returns only one side of the
data, report the missing side and stop the full analysis. If multiple paths are
available, use this precedence unless the user specifies otherwise: uploaded
reports as the audit source, then Lingxing MCP, then Youmai Cloud MCP. Do not
silently merge overlapping sources; show mismatches as a data-quality issue.

## 2. Establish the data contract and time boundary

Before aggregating, identify account, marketplace/site, currency, local
timezone, parent/child ASIN level, report generation time, and covered dates.
Use the site's local calendar date, never the analyst device's timezone. Resolve
the timezone from the report or connector first, then the configured marketplace
timezone; if it cannot be established, mark the report as `时区未确认` and ask
for it rather than silently converting.

Use inclusive local-date windows:

- **今日**: the current local calendar date; label it `进行中` unless the source
  explicitly confirms a completed day.
- **昨日**: the previous local calendar date.
- **近三天**: today and the two preceding local dates.
- **近七天**: today and the six preceding local dates.

For an in-progress Today, do not call a lower total a day-over-day failure
without noting elapsed hours or using a same-elapsed-time comparison. An
inventory number is a point-in-time snapshot at the latest valid local
timestamp, not a sum across days. Keep `可售/可履约库存`, `预留库存`, and
`在途库存` separate when the source provides them.

Read [references/data-contract.md](references/data-contract.md) when the input
uses unfamiliar column names, has multiple report layouts, or needs a formal
field-mapping and risk-threshold decision.

## 3. Normalize without inventing data

Map source fields to these canonical fields while preserving the original
field name and source in the audit notes:

| Area | Canonical fields | Required for the full daily report |
|---|---|---|
| Identity | site, account, local_date, product_key, ASIN, SKU, parent_ASIN, title | site, local_date, product_key or ASIN/SKU |
| Business | sales_amount, currency, units, orders | sales_amount, units, orders |
| Advertising | ad_spend, ad_orders, ad_sales | ad_spend, ad_orders; ad_sales is needed for ACOS |
| Inventory | sellable_units, reserved_units, inbound_units, inventory_timestamp | sellable_units or a clearly equivalent fulfillable-stock field |
| Optional diagnostics | impressions, clicks, CTR, CPC, conversion_rate, returns, refunds, buy_box, listing_status, lead_time_days, safety_stock_days, unit_cost | Use only when present and clearly defined |

Apply these controls:

- Distinguish missing, blank, zero, and not applicable. Missing is never zero.
- Deduplicate on the source's documented grain. Do not add parent and child
  totals together or count a repeated report row twice.
- Keep currencies separate. Convert only with a user-provided or documented
  rate, and show the rate and date.
- If ad attribution uses a different date window or timezone, keep that fact
  visible and do not imply that ad orders are additive to business orders.
- Flag negative sales, units, orders, spend, or inventory; flag ad orders above
  business orders; flag duplicate product keys and inconsistent titles.
- If a required field is absent, produce the supported sections and mark the
  unsupported metric `N/A（源数据缺失）`; never backfill from intuition.

## 4. Calculate the requested metrics

Aggregate business flow fields by site and period, then calculate ratios from
the aggregated numerators and denominators. Do not average daily percentages.

| Metric | Calculation | Interpretation |
|---|---|---|
| 销售额 | Sum of source business sales_amount | Preserve currency and source semantics, such as ordered or shipped sales |
| 销量 | Sum of units | Use the source's unit definition; do not substitute sessions |
| 订单数 | Sum of orders | Keep business orders separate from attributed ad orders |
| 广告费 | Sum of ad_spend | Preserve currency and attribution window |
| 广告花费占比 / TACoS | ad_spend ÷ business sales_amount | Overall sales burden of advertising; denominator zero means N/A |
| 广告订单 | Sum of attributed ad_orders | Attribution may overlap with business orders |
| 广告订单占比 | attributed ad_orders ÷ business orders | Share of orders attributed to ads; denominator zero means N/A |
| 广告销售额 | Sum of ad_sales, if supplied | Use for ad efficiency context, not as total sales unless documented |
| ACOS | ad_spend ÷ ad_sales | Show separately from TACoS; N/A when ad_sales is unavailable or zero |
| 可售库存 | Latest valid local inventory snapshot | Never sum inventory snapshots across days |
| 库存可售天数 | sellable_units ÷ (近七天销量 ÷ 7) | A demand-run-rate estimate; label as estimated when Today is partial |

When the user has not provided targets, do not invent a target ACOS, TACoS,
CPA, lead time, or safety stock. Use `未提供目标` and describe the result as a
signal rather than a pass/fail judgment. If lead time is available, compare
stock cover with `lead_time_days + safety_stock_days`; otherwise use the
conservative fallback bands in the reference and label them `默认预警带`.

## 5. Rank and analyze products

Produce rankings for both Today and Near 7 Days when the data supports both.
Use Near 7 Days as the primary stable ranking when no period is specified. Rank
by units descending for the top five and ascending for the bottom five, with
sales amount as the first tie-breaker and product key as the final tie-breaker.
Include zero-sales products with available inventory in the laggard list. If
fewer than five products qualify, list all and state the count.

For each of the top five and bottom five, provide a compact table containing:

| Product facts | Diagnosis | Action |
|---|---|---|
| ASIN/SKU, title, units, sales, orders, ad spend, TACoS/ACOS, ad-order share, available stock, cover days, Today and 7-day rank | Demand trend, ad dependence, conversion or traffic signal when supported, stock state, and data caveat | One prioritized action, owner suggestion, expected observation window, and stop/rollback condition |

Do not infer conversion problems without clicks/sessions and orders. Do not
call a product “bad” solely because it ranks low; separate low demand, weak
traffic, weak conversion, high ad dependence, price/availability problems, and
insufficient data.

## 6. Risk rules

Use the strongest evidence available and make the reason traceable to fields.
Every risk row should include product, severity, trigger, evidence, action,
and data limitation.

| Risk | High-confidence trigger | Recommended response |
|---|---|---|
| 断货 | sellable_units ≤ 0 while recent demand is positive, listing unavailable, or cover days below known lead time | Escalate replenishment/transfer, protect remaining stock, and review ad budget; do not promise a delivery date |
| 低库存 | cover days ≤ lead time + safety days, or default cover band ≤ 3 days when lead time is unknown | Confirm inbound ETA and demand run rate; mark threshold as estimated if needed |
| 滞销 | sellable_units > 0 and Near 7 Days units = 0; or cover days exceeds 30 days with weak velocity | Pause or reduce inbound, test promotion/bundle/listing improvements, and set a review date |
| 广告浪费信号 | ad_spend > 0 and ad_orders = 0, or ACOS/TACoS exceeds a user-provided target | Inspect search terms/placements and reallocate budget; without a target, label as signal not a verdict |
| 数据异常 | missing date/site, mixed currency, duplicated keys, negative values, ad orders greater than orders, or incomplete coverage | Exclude only the affected calculation, show the anomaly, and request correction |

Use severity `P0`, `P1`, `P2` and explain the threshold. A `P0` risk needs
same-day attention; `P1` needs action within the next operating cycle; `P2`
needs monitoring. Do not upgrade a risk solely because a product is in the
bottom five.

## 7. Required Chinese report format

Use Markdown tables for comparisons and data. Lead with the conclusion, then
show evidence. Keep raw source names and time coverage in the report so an
operator can audit it.

```text
# 亚马逊运营日报分析｜站点｜站点今日日期

## 0. 今日结论
用 3-6 条写销售、广告、库存和最重要风险；今日未完结时写明。

## 1. 数据源、范围与口径
表格：数据源、站点、币种、时区、覆盖日期、数据粒度、状态、优势、局限。

## 2. 核心指标汇总
表格行：今日、昨日、近三天、近七天。
表格列：销售额、销量、订单数、广告费、广告花费占比、广告订单、广告订单占比、广告销售额、ACOS、可售库存、库存可售天数。

## 3. 趋势与原因
按销售、广告、库存分别写事实、证据、可能原因、仍需验证的假设。

## 4. 销量前五产品
先给排名表，再逐个给产品事实-判断-动作表。

## 5. 销量最差五个产品
先给排名表，再逐个给产品事实-判断-动作表；零销量和有库存优先突出。

## 6. 风险清单
表格列：优先级、风险类型、产品/范围、触发证据、影响、建议动作、负责人、复核时间、数据限制。

## 7. 今日行动清单
按 P0/P1/P2 排序，写动作、验收指标、复盘时间；没有目标值时明确需要补充目标。

## 8. 数据质量与待补字段
只列会影响结论的缺口，不用缺失数据填零。
```

If a required section cannot be supported, keep its heading and write the
precise reason. End with a short `优先级排序的优势与局限` table when
recommendations compete for resources: explain why the chosen order protects
revenue or cash first, and what the ranking cannot establish without more data.
