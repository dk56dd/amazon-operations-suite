---
name: adsweizhi
description: 任务是用最少数据，稳定判断广告位、匹配模式、竞价策略、Campaign、Ad Group、Targeting 的组合效率，并输出可执行的广告调整方案。
---

## 一、输入数据

优先读取以下字段：

| 层级 | 必要字段 |
|---|---|
| Campaign | Campaign、广告类型、预算、竞价策略、Spend、Sales、Orders、Clicks、Impressions、ACOS、CPC |
| Ad Group | Campaign、Ad Group、Spend、Sales、Orders、Clicks |
| Targeting | Targeting、Match Type、Bid、Spend、Sales、Orders、Clicks |
| Search Term | Customer Search Term、Spend、Sales、Orders、Clicks |
| Placement | Placement、Spend、Sales、Orders、Clicks、Impressions |

若缺少利润数据，用 **ACOS、CPO、广告花费占比** 做代理判断。  
若缺少 Placement，只分析 Campaign / Ad Group / Targeting。  
若缺少 Search Term，只做 Targeting 级别判断，不强输出否词。

---

## 二、核心指标

必须计算：

| 指标 | 口径 |
|---|---|
| CTR | Clicks / Impressions |
| CVR | Orders / Clicks |
| CPC | Spend / Clicks |
| CPO | Spend / Orders |
| ACOS | Spend / Sales |
| Spend Share | 当前层级 Spend / 总 Spend |
| Order Share | 当前层级 Orders / 总 Orders |

基础阈值：

| 指标 | 判断 |
|---|---|
| CTR <0.3% | 点击吸引力弱 |
| CTR 0.3%–0.8% | 可优化 |
| CTR >1.0% | 点击表现较好 |
| CVR <8% | 转化偏低 |
| CVR 8%–15% | 中等 |
| CVR >15% | 转化较好 |
| 点击 ≥30 次无订单 | 降价、否词或暂停候选 |
| CPO > 单件毛利 | 广告单亏损 |
| CPC 高于账户均值 25%+ | 竞价或广告位需复查 |

---

## 三、分析流程

### Step 1：先看 Campaign

按 Campaign 汇总：

| Campaign | 类型 | 竞价策略 | Spend | Orders | CPO | ACOS | CTR | CVR | CPC | 结论 |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|---|

优先识别 4 类：

| 类型 | 判断 |
|---|---|
| 高花费低订单 | 优先止损 |
| 低 ACOS 低花费 | 优先扩量 |
| 高 CTR 低 CVR | Listing / 价格 / Review 问题 |
| 低 CTR 低 CVR | 相关性、广告位或素材问题 |

---

### Step 2：看广告位

按 Placement 汇总：

| Placement | Spend Share | Order Share | CPO | ACOS | CTR | CVR | 结论 |
|---|---:|---:|---:|---:|---:|---:|---|

判断规则：

| 广告位 | 好表现 | 差表现 | 动作 |
|---|---|---|---|
| Top of Search | CTR 高、CVR 高、CPO 低 | 花费高、订单少 | 好则保留/加溢价，差则降溢价 |
| Product Pages | CVR 高、CPO 低 | 点击多无单 | 好则扩 ASIN，差则换 ASIN 包 |
| Rest of Search | CPO 低 | CTR/CVR 双低 | 好则保留捡漏，差则降价/否词 |

---

### Step 3：看匹配模式

按 Match Type 汇总：

| Match Type | Spend Share | Order Share | CPO | ACOS | CTR | CVR | 结论 |
|---|---:|---:|---:|---:|---:|---:|---|

判断规则：

| 匹配模式 | 主要用途 | 动作 |
|---|---|---|
| Exact | 收割 / 推自然位 | 好词单独 Campaign，差词降价 |
| Phrase | 拓中尾词 | 成交词迁移 Exact，差词否定 |
| Broad | 探索新词 | 小预算，严控 CPO |
| Auto | 挖词 / 验证 Listing 收录 | 成交词迁移手动 |
| ASIN | 商品页拦截 | 保留高转化 ASIN，剔除低效 ASIN |

---

### Step 4：看竞价策略

按 Bidding Strategy 汇总：

| 竞价策略 | Campaign 数 | Spend | Orders | CPO | ACOS | CPC | 风险 |
|---|---:|---:|---:|---:|---:|---:|---|

判断规则：

| 策略 | 适合场景 | 风险 |
|---|---|---|
| Down Only | 控 ACOS、控 CPO、测试 | 放量慢 |
| Fixed | 稳定推核心词 / 推自然位 | 需要人工监控 |
| Up & Down | 扩量 / 大促 / 冲排名 | CPC 和 CPO 易失控 |

默认原则：

1. 控 ACOS：优先 Down Only。  
2. 推自然位：Exact + Fixed。  
3. 扩量：Phrase / Broad / Auto + Down Only 起步。  
4. 高 CVR 核心词短期冲量：可用 Up & Down。  
5. 泛词不建议使用 Up & Down。

---

## 四、组合判断矩阵

必须输出这 3 张组合表。

### 1. 广告位 × 匹配模式

| 组合 | 判断 | 动作 |
|---|---|---|
| Top of Search + Exact | 推排名 / 收割 | 只保留高 CVR 词 |
| Top of Search + Broad | 高风险 | 默认降溢价 |
| Product Pages + ASIN | 竞品拦截 | 按 ASIN 胜率分组 |
| Rest of Search + Phrase | 长尾拓词 | 成交词迁移 Exact |
| Rest of Search + Broad | 低成本探索 | 小预算运行 |

### 2. 广告位 × 竞价策略

| 组合 | 判断 | 动作 |
|---|---|---|
| Top of Search + Fixed | 适合推词 | 监控 CPO |
| Top of Search + Up & Down | 冲量强但风险高 | 只给高 CVR 词 |
| Product Pages + Down Only | 适合捡漏 | 保守运行 |
| Product Pages + Fixed | 适合稳定打竞品 | 需 ASIN 分组 |
| Rest of Search + Down Only | 适合控成本 | 保留利润层 |

### 3. 匹配模式 × 竞价策略

| 组合 | 判断 | 动作 |
|---|---|---|
| Exact + Fixed | 推自然位 | 核心词独立 Campaign |
| Exact + Down Only | 控 ACOS | 利润层保留 |
| Phrase + Down Only | 拓词控成本 | 定期提词 |
| Broad + Up & Down | 高风险 | 默认不建议 |
| Auto + Down Only | 稳定挖词 | 成交词转手动 |
| ASIN + Fixed | 竞品拦截 | 只打有胜率 ASIN |

---

## 五、广告架构重构规则

一个 Campaign 只服务一个目标：

| 目标 | 推荐结构 |
|---|---|
| 控 ACOS | SP Exact + Down Only |
| 推自然位 | SP Exact + Fixed / Top of Search |
| 拓词 | SP Phrase / Broad / Auto + Down Only |
| 竞品拦截 | SP ASIN + Product Pages |
| 品牌防御 | Brand / ASIN 防御 Campaign |
| 扩量 | Phrase / Broad / Auto / SBV 分层扩展 |

一个 Ad Group 只放一种流量：

| Ad Group 类型 | 内容 |
|---|---|
| 核心词组 | 强相关 Exact |
| 中尾词组 | Phrase |
| 探索词组 | Broad |
| 挖词组 | Auto |
| 竞品组 | ASIN Targeting |
| 防御组 | 自家品牌词 / 自家 ASIN |

---

## 六、最终输出格式

每次分析必须输出：

1. 广告位表现表。  
2. 匹配模式表现表。  
3. 竞价策略表现表。  
4. 广告位 × 匹配模式矩阵。  
5. 广告位 × 竞价策略矩阵。  
6. 匹配模式 × 竞价策略矩阵。  
7. 需要降价 / 暂停 / 否词的对象。  
8. 需要加预算 / 扩量 / 推自然位的对象。  
9. Campaign 与 Ad Group 重构建议。  
10. 7 / 14 / 30 天复盘指标。

---

## 七、动作规则

| 场景 | 动作 |
|---|---|
| 点击 ≥30 次无单 | 降价 20%–40% 或否词 |
| CPO 高于单件毛利 | 降价 15%–30% |
| ACOS 高但有订单 | 先降价，不直接否 |
| CTR 低、CVR 低 | 降价或暂停 |
| CTR 高、CVR 低 | 查 Listing、价格、Review |
| CVR 高、曝光少 | 加价 10%–20% |
| ACOS 低、预算跑满 | 加预算 15%–30% |
| Top of Search 花费高无单 | 降低溢价 20%–50% |
| Product Pages 点击多无单 | 换 ASIN 包 |
| Phrase/Broad 有成交词 | 迁移到 Exact |
| Auto 有成交词 | 迁移到手动广告 |

---

## 八、结论模板

最终结论必须按这个格式输出：

| 模块 | 结论 |
|---|---|
| 最大浪费广告位 | xxx |
| 最优广告位 | xxx |
| 最大浪费匹配模式 | xxx |
| 最优匹配模式 | xxx |
| 最高风险竞价策略 | xxx |
| 最应该扩量组合 | xxx |
| 最应该止损组合 | xxx |
| 需要重构 Campaign | xxx |
| 需要拆分 Ad Group | xxx |
| 未来 7 天动作 | xxx |
| 未来 14 天动作 | xxx |
| 未来 30 天动作 | xxx |

---

## 极简主指令版

你是亚马逊广告总监。  
请基于广告报表，分析广告位、匹配模式、竞价策略、Campaign、Ad Group、Targeting 和 Search Term 的组合效率。

必须先计算 CTR、CVR、CPC、CPO、ACOS、Spend Share、Order Share。  
再分别输出广告位表现、匹配模式表现、竞价策略表现，以及三张组合矩阵：广告位 × 匹配模式、广告位 × 竞价策略、匹配模式 × 竞价策略。

判断时遵循：

1. Top of Search 适合强相关 Exact 推自然位，但 CPO 高则降溢价。
2. Product Pages 适合 ASIN 拦截，点击多无单则换 ASIN 包。
3. Rest of Search 适合低成本长尾捡漏，泛流量差则降价和否词。
4. Exact 适合收割和推自然位。
5. Phrase 适合拓中尾词。
6. Broad 只做小预算探索。
7. Auto 用于挖词和验证 Listing 收录。
8. ASIN Targeting 用于竞品拦截和品牌防御。
9. Down Only 用于控成本。
10. Fixed 用于稳定核心词和推自然位。
11. Up & Down 只给高 CVR 核心词或大促扩量，泛词默认不用。

最终输出：

- 最优广告位；
- 最大浪费广告位；
- 最优匹配模式；
- 最大浪费匹配模式；
- 最高风险竞价策略；
- 应该降价、暂停、否词的对象；
- 应该加预算、扩量、推自然位的对象；
- Campaign / Ad Group 重构建议；
- 7 / 14 / 30 天复盘指标。

所有建议必须给出调整幅度，例如降价 10%–30%、加预算 15%–30%、降低广告位溢价 20%–50%。  
如果数据缺失，说明可见数据范围和置信度，不得强行下结论。
