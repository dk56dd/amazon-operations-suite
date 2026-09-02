---
name: weather-product-impact
description: 当用户需要分析天气对产品、ASIN、Amazon广告、选品、库存、物流、销售波动或季节性需求的影响时使用本技能。尤其适用于用户提供产品链接、产品ASIN、产品信息、站点国家、销售/广告数据后，需要联网获取温度、湿度、天气状况，并输出可执行运营判断、风险、机会和动作清单。
---

# 天气产品影响分析 Skill

## 技能命名

| 类型 | 名称 |
| --- | --- |
| 中文名 | 天气产品影响分析 |
| English name | weather-product-impact |

## 适用场景

当用户希望判断“天气变化会不会影响某个产品/ASIN/品类的销售、广告、库存、物流、退货或选品机会”时使用本技能。默认面向 Amazon 运营、Amazon 广告、Amazon 选品，也可泛化到独立站、线下零售、跨境电商和本地生活产品。

典型触发语包括：

- “分析天气对这个产品的影响”
- “这个 ASIN 受温度/湿度/下雨/暴雪影响吗”
- “结合天气看广告预算怎么调”
- “按国家天气判断产品旺季/淡季”
- “找天气驱动型选品机会”
- “天气变冷/变热后哪些关键词、广告、库存要调整”

## 开始分析前的硬性前置检查

在正式分析前，先确认联网搜索功能是否开启。只有确认可联网后，才能继续天气数据采集和结论输出。

执行顺序：

1. 检查当前环境是否有可用的联网搜索/浏览工具。
2. 立刻做一次轻量联网验证，例如打开 [Open-Meteo](https://open-meteo.com/) 或 [WMO World Weather Information Service](https://worldweather.wmo.int/)。
3. 如果联网失败，停止分析，并回复用户：`当前联网搜索不可用，无法可靠获取最新天气数据。请开启联网搜索后再继续。`
4. 如果联网成功，在报告开头写明：`联网搜索状态：已验证可用`，并记录验证时间和使用的数据源。

为什么要这样做：天气是强时效数据，不能用模型记忆或过期缓存替代实时查询。没有联网验证时，不输出天气驱动的运营结论。

## 必须向用户索取的信息

开始前先检查用户是否提供了足够产品信息。缺少关键项时，不要硬编产品属性。

| 信息项 | 必填/可选 | 用途 | 缺失时处理 |
| --- | --- | --- | --- |
| 产品链接 | 推荐必填 | 识别站点、类目、卖点、价格、变体、图片语义 | 让用户补充，或只做通用品类分析 |
| 产品 ASIN | Amazon 场景必填 | 定位具体商品、广告对象、竞品和评论语义 | 让用户补充，不能凭链接外观猜测 |
| 产品名称/类目 | 必填 | 判断天气敏感性和替代场景 | 让用户补充最短描述 |
| 产品核心功能 | 必填 | 建立天气影响路径，如保暖、防潮、降温、户外、清洁 | 让用户补充 |
| 目标国家/站点 | 必填 | 决定天气源、地区、季节和时区 | 让用户指定国家、州/省、市 |
| 销售区域/仓储区域 | 推荐必填 | 区分需求端天气和供应链天气 | 缺失则默认只分析销售端 |
| 时间范围 | 推荐必填 | 当前天气、未来7-16天、历史同期、季节趋势 | 缺失则默认当前日期起未来14天 |
| 销售/广告数据 | 可选 | 验证天气与销量、CTR、CVR、CPC、ACOS 的关系 | 没有数据时只做假设分级，不做因果断言 |
| 竞品/关键词 | 可选 | 判断天气触发关键词和广告机会 | 缺失则从类目泛化 |

## 天气数据维度

最小天气维度固定为三类：温度、湿度、天气。

| 维度 | 推荐字段 | 运营解释 |
| --- | --- | --- |
| 温度 | `temperature_2m`、最高温、最低温、体感温度 | 影响保暖、降温、户外、车载、家居、宠物、母婴、服饰等需求 |
| 湿度 | `relative_humidity_2m`、露点、降水概率 | 影响防潮、除湿、霉菌、清洁、护肤、包装、仓储、电子产品风险 |
| 天气 | `weather_code`、晴/雨/雪/雾/风暴、降水、降雪 | 影响出行、户外活动、应急用品、物流延误、搜索意图和广告素材 |

可扩展维度：风速、紫外线、空气质量、降水量、降雪量、能见度、极端天气预警、热浪/寒潮、台风/飓风、火灾烟霾、花粉、日照时长。只有当产品机制相关时才扩展，不要为了堆数据而扩展。

## 推荐免费天气数据源优先级

| 优先级 | 数据源 | 适用 | 优势 | 局限 |
| --- | --- | --- | --- | --- |
| 1 | 各国官方气象机构官网，见本文“国家/地区免费天气官网索引” | 国家级权威天气、预警、极端天气 | 官方、可解释、适合报告引用 | 格式不统一，部分国家 API 不开放或语言不同 |
| 2 | [Open-Meteo](https://open-meteo.com/) / [API 文档](https://open-meteo.com/en/docs) | 全球当前、预报、历史天气，适合自动化 | 免费额度友好、无需 key、字段统一、支持温度/湿度/天气码 | 商用高频调用需检查条款，局地预警不如官方源 |
| 3 | [WMO World Weather Information Service](https://worldweather.wmo.int/) | 官方城市天气、气候信息、国家入口 | WMO 汇聚官方成员数据，适合跨国索引 | 城市覆盖不等，接口字段需要解析 |
| 4 | [WMO Contacts Directory](https://contacts.wmo.int/) | 查找所有 WMO 成员和气象机构联系/官网 | 覆盖 WMO 193 成员信息 | 更偏目录，不一定直接提供天气 API |
| 5 | 国家或区域专题源，如 [NOAA/NWS](https://www.weather.gov/)、[DWD](https://www.dwd.de/)、[MET Norway](https://www.met.no/)、[BOM Australia](https://www.bom.gov.au/) | 重点市场深挖 | 区域精度高、预警强 | 跨国一致性差 |

## Open-Meteo 快速调用模板

用于快速获取温度、湿度、天气码。先把用户目标市场解析成经纬度，再替换 URL 中的 `latitude` 和 `longitude`。

```text
https://api.open-meteo.com/v1/forecast?latitude=LAT&longitude=LON&current=temperature_2m,relative_humidity_2m,weather_code&hourly=temperature_2m,relative_humidity_2m,weather_code,precipitation_probability,precipitation&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&forecast_days=14&timezone=auto
```

历史同期分析模板：

```text
https://archive-api.open-meteo.com/v1/archive?latitude=LAT&longitude=LON&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD&hourly=temperature_2m,relative_humidity_2m,weather_code,precipitation&timezone=auto
```

## 分析流程

1. 确认联网搜索已开启，并记录验证来源。
2. 读取用户提供的产品链接、ASIN、产品信息和目标国家/地区。
3. 拆解产品天气敏感机制：需求端、使用端、仓储端、物流端、广告端、退货端。
4. 按国家/城市获取天气数据，至少包含温度、湿度、天气状况；时间范围默认未来14天，并可补历史同期。
5. 对比当前天气、未来天气、历史同期和产品使用场景，判断影响方向。
6. 输出结论时区分“证据支持”“合理推断”“需要补数据验证”，不要把相关性写成因果。
7. 给出 Amazon 运营动作：广告预算、关键词、素材、库存、价格、优惠、Listing 卖点、物流提醒、客服预案。
8. 如果涉及多国家、多 ASIN、多品类对比，用表格展示，并明确优劣势。

## 天气对产品影响的判断框架

| 影响模块 | 看什么天气 | 可能正向影响 | 可能负向影响 | 应对动作 |
| --- | --- | --- | --- | --- |
| 需求 | 温度、天气、季节突变 | 高温带动降温、防晒、户外饮水；低温带动保暖、室内、取暖 | 反季、极端天气减少户外消费 | 调整预算、关键词和主图卖点 |
| 广告 | 温度趋势、降雨/降雪、预警 | 天气触发搜索词上升，CTR/CVR 改善 | CPC 被竞品抢高，流量短期波动 | 分时分区加预算，单独建天气关键词组 |
| 库存 | 未来7-30天天气 | 旺季提前补货，避免断货 | 天气转弱导致积压 | 设置安全库存和清仓阈值 |
| 物流 | 暴雨、暴雪、台风、极端高温 | 应急产品需求上升 | 配送延误、差评、退货 | 提前改 ETA 文案和客服模板 |
| 仓储 | 湿度、温度、降水 | 防潮类产品机会 | 霉变、包装损坏、电池/液体风险 | 检查包装、防潮剂、FBA 限制 |
| 评价/退货 | 天气与使用场景不匹配 | 使用效果更明显 | 用户误用、尺寸/材质不适 | 优化 FAQ、说明书、售后话术 |

## 输出报告模板

每次使用本技能，优先用以下结构输出：

```markdown
# 天气对产品影响分析报告

## 结论先行
- 联网搜索状态：已验证可用 / 不可用
- 产品：
- ASIN：
- 目标国家/地区：
- 时间范围：
- 总判断：正向 / 负向 / 中性 / 不确定
- 建议动作：

## 输入信息完整性
| 信息项 | 用户是否提供 | 备注 |
| --- | --- | --- |

## 天气数据摘要
| 地区 | 日期范围 | 温度 | 湿度 | 天气 | 数据源 | 可信度 |
| --- | --- | --- | --- | --- | --- | --- |

## 产品影响矩阵
| 影响方向 | 影响链路 | 证据 | 机会 | 风险 | 建议动作 |
| --- | --- | --- | --- | --- | --- |

## 广告与运营动作
| 动作 | 优势 | 劣势/风险 | 执行条件 | 优先级 |
| --- | --- | --- | --- | --- |

## 需要用户补充的数据
- 
```

## Amazon 场景专项规则

- 不要只看国家平均天气；Amazon 广告和销量通常受主要购买州/城市影响。美国至少拆 CA/TX/FL/NY/IL 等核心区域，欧洲按国家拆，澳洲按州/主要城市拆。
- ASIN 没有明确提供时，不要猜测。可以基于产品描述做“品类级天气假设”，但必须标注为假设。
- 广告建议必须落到可执行层：预算、竞价、关键词、否词、广告组、Placement、素材卖点、优惠节奏。
- 天气触发词要结合产品：如 `hot weather`、`rainy day`、`winter`、`humid room`、`snow storm`、`summer travel`、`hurricane supplies` 等，不要机械堆词。
- 如果用户提供广告数据，优先验证天气变化前后 CTR、CVR、CPC、ACOS、TACOS、销量、自然排名，不只看曝光。

## 泛化规则

预留泛化时，不把技能锁死在 Amazon。若用户给的是 Shopify、独立站、沃尔玛、TikTok Shop、线下门店或 B2B 产品，仍按同一逻辑执行：产品机制 -> 地区天气 -> 需求/履约/库存/营销影响 -> 可执行动作。

泛化分类示例：

| 产品类型 | 关键天气变量 | 影响方向 |
| --- | --- | --- |
| 户外用品 | 温度、降水、风速、紫外线 | 决定使用频率和购买急迫性 |
| 家居除湿/清洁 | 湿度、降雨、霉菌季节 | 高湿地区需求增强 |
| 服饰鞋靴 | 温度、降雪、降雨 | 季节切换直接影响转化 |
| 车载用品 | 高温、低温、降雪、暴晒 | 影响遮阳、除冰、应急需求 |
| 宠物用品 | 高温、低温、降雨 | 影响出行、保暖、降温、清洁 |
| 食品/保健 | 高温、湿度、季节病 | 影响储存、配送和需求场景 |
| 电子/电池 | 高温、湿度、极端天气 | 影响仓储、运输、故障和退货 |

## 风险控制

- 不使用过期天气记忆直接下结论。
- 不把“天气相似”直接等同于“销量一定上涨”。
- 不忽略时区和日期，报告必须写绝对日期。
- 不混用摄氏和华氏；默认按目标站点习惯展示，并保留单位。
- 不把全国天气平均值用于城市级运营动作。
- 不引用需要付费或登录才能验证的数据作为唯一证据。
- 如果数据源之间冲突，优先官方气象机构，其次 Open-Meteo，再次商业/聚合网站，并说明差异。

## 免费天气入口总索引

| 类型 | 链接 | 用法 |
| --- | --- | --- |
| WMO 官方全球天气 | [World Weather Information Service](https://worldweather.wmo.int/) | 查官方城市天气、国家/地区页面、气象服务官网 |
| WMO 参与成员官网目录 | [Participating Members](https://worldweather.wmo.int/en/members.html) | 查各国/地区官方气象机构官网 |
| WMO 国家数据接口 | [Country_en.xml](https://worldweather.wmo.int/en/json/Country_en.xml) | 机器可读的国家/地区、机构、官网、城市天气索引 |
| WMO 区域数据接口 | [Region_en.xml](https://worldweather.wmo.int/en/json/Region_en.xml) | 按洲/区域查参与成员 |
| WMO 联系目录 | [Contacts Directory](https://contacts.wmo.int/) | 查 WMO 成员、代表和机构信息 |
| Open-Meteo 全球免费 API | [Open-Meteo](https://open-meteo.com/) | 全球天气预报、历史天气、温度、湿度、天气码 |
| Open-Meteo API 文档 | [Weather Forecast API](https://open-meteo.com/en/docs) | 拼接 API 获取温度、湿度、天气、降水等字段 |
| WMO 农业气象 | [World AgroMeteorological Information Service](http://www.wamis.org/) | 农产品、农业天气、种植相关分析 |
| WMO 极端天气档案 | [World Weather / Climate Extremes Archive](http://wmo.asu.edu/) | 极端天气背景和历史案例 |
| WMO 预警机构登记 | [Register of Alerting Authorities](https://alertingauthority.wmo.int/) | 查官方预警发布机构 |

## 国家/地区免费天气官网索引（WMO 参与成员）

说明：以下表格依据 WMO World Weather Information Service 的国家/地区数据接口整理。优先给出官方气象机构官网；WMO 未在字段中列出官网时，给出对应 WMO 国家/地区页，供联网搜索继续跳转核验。部分官网可能调整域名或访问策略，使用时先实时打开验证。

| 国家/地区 | 气象机构 | 免费天气入口 |
| --- | --- | --- |
| Afghanistan | Afghanistan Meteorological Authority (AMA) | [官网](https://www.amd.gov.af) |
| Albania | The Hydrometeorological Institute | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=102) |
| Algeria | National Meteorological Office | [官网](https://www.meteo.dz) |
| Andorra | Servei meteorològic d'Andorra | [官网](https://www.meteo.ad) |
| Angola | Instituto Nacional de Hidrometeorología e Geofísica | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=129) |
| Antigua and Barbuda | Antigua and Barbuda Meteorological Services | [官网](https://www.antiguamet.com) |
| Argentina | Servicio Meteorológico Nacional | [官网](https://www.smn.gov.ar) |
| Armenia | Hydrometeorology and Monitoring Center SNCO | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=18) |
| Australia | Bureau of Meteorology | [官网](https://www.bom.gov.au) |
| Austria | GeoSphere Austria | [官网](https://www.geosphere.at) |
| Azerbaijan | National Hydrometeorological Department | [官网](https://www.eco.gov.az) |
| Bahamas | Bahamas Department of Meteorology | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=25) |
| Bahrain | Bahrain Meteorological Services | [官网](https://www.bahrainweather.gov.bh) |
| Bangladesh | Bangladesh Meteorological Department | [官网](https://www.bmd.gov.bd/?/home) |
| Barbados | Barbados Meteorological Services | [官网](https://www.barbadosweather.org) |
| Belarus | Republican center for hydrometeorology, control of radioactive contamination and enviromental monitoring | [官网](https://belgidromet.by) |
| Belgium | Institut Royal Météorologique | [官网](https://www.meteo.be) |
| Belize | National Meteorological Service of Belize | [官网](https://www.nms.gov.bz) |
| Benin | Agence Nationale de la Meteorologie (METEO BENIN) | [官网](https://www.meteobenin.bj) |
| Bhutan | National Center for Hydrology and Meteorology (NCHM) | [官网](https://www.nchm.gov.bt) |
| Bolivia (Plurinational State of) | Servicio Nacional de Meteorología e Hidrología | [官网](https://www.senamhi.gob.bo) |
| Bosnia and Herzegovina | Federal Hydrometeorological Service of the Federation of Bosnia and Herzegovina | [官网](https://www.fhmzbih.gov.ba) |
| Botswana | Botswana Meteorological Services | [官网](https://www.weather.info.bw) |
| Brazil | Instituto Nacional de Meteorologia | [官网](https://portal.inmet.gov.br) |
| British Caribbean Territories | Cayman Island National Weather Service | [官网](https://www.gov.ky) |
| Brunei Darussalam | Brunei Darussalam Meteorological Department | [官网](https://www.met.gov.bn) |
| Bulgaria | National Institute of Meteorology and Hydrology | [官网](https://www.meteo.bg/en) |
| Burkina Faso | Agence Nationale de la Météorologie du Burkina Faso | [官网](https://www.meteoburkina.bf) |
| Burundi | Institut Géographique du Burundi (IGEBU) | [官网](https://www.igebu.bi) |
| Cabo Verde | Instituto Nacional De Meteorologia E Geofisica De Cabo Verde | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=100) |
| Cambodia | Ministry of Water Resources and Meteorology | [官网](https://mowram.gov.kh) |
| Cameroon | Direction de la Meteorologie Nationale | [官网](https://www.meteo-cameroon.net) |
| Canada | Meteorological Service of Canada | [官网](https://weather.gc.ca/canada_e.html) |
| Central African Republic | Direction de la Meteorologie et de l'hydrologie (DMH) | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=146) |
| Chad | Agence Nationale de la Météorologie | [官网](https://www.meteotchad.org) |
| Chile | Dirección Meteorológica de Chile | [官网](https://www.meteochile.cl) |
| China | China Meteorological Administration | [官网](https://www.cma.gov.cn/en2014/) |
| Colombia | Institute of Hydrology, Meteorology and Environment Studies | [官网](https://www.ideam.gov.co) |
| Comoros | Direction de la Météorologie Nationale | [官网](https://www.anacm-comores.com) |
| Congo | Direction de la Météorologie Nationale | [官网](https://dirmet.cg) |
| Cook Islands | Cook Islands Meteorological Service | [官网](https://www.cookislands.pacificweather.org) |
| Costa Rica | Instituto Meteorológico Nacional | [官网](https://www.imn.ac.cr/) |
| Croatia | Croatian Meteorological and Hydrological Service | [官网](https://meteo.hr/index_en.php) |
| Cuba | Instituto de Meteorología | [官网](https://www.insmet.cu) |
| Curaçao and Sint Maarten | Meteteorological Department Curacao | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=181) |
| Cyprus | Department of Meteorology | [官网](https://www.moa.gov.cy/ms) |
| Czechia | Czech Hydrometeorological Institute | [官网](https://www.chmi.cz) |
| Côte d'Ivoire | SODEXAM (Societe d'Exploitation et de Developpement Aeroportuaire, Aeronautique et Meteorologique) | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=149) |
| Democratic People's Republic of Korea | State Hydrometeorological Administration(SHMA) | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=120) |
| Democratic Republic of the Congo | Agence Nationale de Meteorologie et de Teledetection par Satellite (METTELSAT) | [官网](https://meteordcongo.cd) |
| Denmark | Danish Meteorological Institute | [官网](https://www.dmi.dk/eng/index/forecasts.htm) |
| Djibouti | Agence Nationale de la Météorologie de Djibouti (ANM) | [官网](https://meteodjibouti.dj) |
| Dominica | Dominica Meteorological Service | [官网](https://www.weather.gov.dm) |
| Dominican Republic | Oficina Nacional de Meteorologiá | [官网](https://www.onamet.gov.do) |
| Ecuador | Instituto Nacional de Meteorología e Hidrología - INAMHI | [官网](https://www.inamhi.gob.ec) |
| Egypt | The Egyptian Meteorological Authority (EMA) | [官网](https://ema.gov.eg) |
| El Salvador | Gerencia de Meteorología | [官网](https://www.marn.gob.sv) |
| Eritrea | Civil Aviation Authority | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=42) |
| Estonia | Estonian Meteorological and Hydrological Institute | [官网](https://www.emhi.ee/?nlan=eng) |
| Eswatini | Eswatini Meteorological Service | [官网](https://www.swazimet.gov.sz) |
| Ethiopia | Ethiopian Meteorological Institute (EMI) | [官网](https://www.ethiomet.gov.et) |
| Fiji | Fiji Meteorological Service | [官网](https://www.met.gov.fj) |
| Finland | Finnish Meteorological Institute | [官网](https://www.fmi.fi/en/index.html) |
| France | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Guadeloupe | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Guiana | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - La Réunion | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Martinique | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Mayotte | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Saint-Barthélemy | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Saint-Martin | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Saint-Pierre-et-Miquelon | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| France - Wallis-et-Futuna | Météo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| French Polynesia | Meteo-France | [官网](https://www.meteo.fr/meteonet_en/index.htm) |
| Gabon | Direction Generale de la Meteorologie | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=128) |
| Gambia (The) | Department of Water Resources | [官网](https://meteogambia.gm) |
| Georgia | Department of Hydrometeorology | [官网](https://www.meteo.gov.ge) |
| Germany | Deutscher Wetterdienst | [官网](https://www.dwd.de) |
| Ghana | Ghana Meteorological Agency | [官网](https://www.meteo.gov.gh) |
| Greece | Hellenic National Meteorological Service | [官网](https://www.hnms.gr) |
| Guatemala | Instituto Nacional de Sismología, Vulcanología, Meteorología e Hidrología (INSIVUMEH) | [官网](https://www.insivumeh.gob.gt) |
| Guinea | Agence Nationale de la Météorologie | [官网](https://anmeteo.gov.gn) |
| Guinea-Bissau | Instituto Nacional de Meteorologia da Guiné-Bissau | [官网](https://meteoguinebissau.gw) |
| Guyana | Hydrometeorological Service | [官网](https://www.hydromet.gov.gy) |
| Haiti | Unité Hydrométéorologique d’Haïti (UHM) | [官网](https://www.meteo-haiti.gouv.ht/index.html) |
| Honduras | Centro Nacional de Estudios Atmosféricos, Oceanográficos y Sísmicos | [官网](https://www.smn.gob.hn) |
| Hong Kong, China | Hong Kong Observatory | [官网](https://www.weather.gov.hk) |
| Hungary | Hungarian Meteorological Service | [官网](https://www.met.hu) |
| Iceland | Icelandic Meteorological Office | [官网](https://www.vedur.is/english) |
| India | India Meteorological Department | [官网](https://mausam.imd.gov.in) |
| Indonesia | Meteorological, Climatological and Geophysical Agency (BMKG) | [官网](https://www.bmkg.go.id) |
| Iran (Islamic Republic of) | Islamic Repulic of Iran Meteorogical Organization (IRIMO) | [官网](https://www.irimo.ir/eng/index.php) |
| Iraq | Iraqi Meteorological Organization and Seismology | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=154) |
| Ireland | Met Éireann, The Irish Meteorological Service | [官网](https://www.met.ie) |
| Israel | Israel Meteorological Service | [官网](https://ims.gov.il/en) |
| Italy | Italian Air Force- Department of Meteorology | [官网](https://www.meteoam.it) |
| Jamaica | Meteorological Service, Jamaica | [官网](https://www.metservice.gov.jm) |
| Japan | Japan Meteorological Agency | [官网](https://www.jma.go.jp/jma/indexe.html) |
| Jordan | Jordan Meteorological Department | [官网](https://www.jometeo.gov.jo) |
| Kazakhstan | Ministry of Energy of the Republic of Kazakhstan | [官网](https://www.kazhydromet.kz) |
| Kenya | Kenya Meteorological Department | [官网](https://www.meteo.go.ke/) |
| Kiribati | Kiribati Meteorological Service | [官网](https://www.climate.gov.ki) |
| Kuwait | Meteorological Department | [官网](https://www.met.gov.kw) |
| Kyrgyzstan | Kyrgyzhydromet | [官网](https://meteo.kg) |
| Lao People's Democratic Republic | Department of Meteorology and Hydrology (DMH), Lao PDR | [官网](https://dmhlao.etllao.com) |
| Latvia | Latvian Environment, Geology and Meteorology Centre | [官网](https://www.meteo.lv/en/) |
| Lebanon | Service Météorologique | [官网](https://www.dgca.gov.lb/index.php/en/meteo-en) |
| Lesotho | Lesotho Meteorological Services | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=155) |
| Liberia | Liberia Meteorological Service (LMS), Ministry of Transport | [官网](https://meteoliberia.com) |
| Libya (State of) | National Meteorological Centre | [官网](https://www.lnmc.ly) |
| Lithuania | Lithuanian Hydrometeorological Service | [官网](https://www.meteo.lt/) |
| Luxembourg | Air Navigation Administration (ANA), Meteolux | [官网](https://www.meteolux.lu) |
| Macao, China | Macao Meteorological and Geophysical Bureau | [官网](https://www.smg.gov.mo/en) |
| Madagascar | Direction Générale de la Météorologie | [官网](https://www.meteomadagascar.mg) |
| Malawi | Department of Climate Change and Meteorological Services | [官网](https://www.metmalawi.gov.mw) |
| Malaysia | Malaysian Meteorological Department | [官网](https://www.met.gov.my) |
| Maldives | Maldives Meteorological Service | [官网](https://www.meteorology.gov.mv) |
| Mali | Agence Nationale de la Météorologie du Mali (MALI-METEO) | [官网](https://www.malimeteo.ml) |
| Malta | Meteorological Office | [官网](https://www.maltairport.com/weather/) |
| Mauritania | Office National de la Météorologie | [官网](https://meteomauritanie.mr) |
| Mauritius | Mauritius Meteorological Services | [官网](https://metservice.intnet.mu) |
| Mexico | Coordinación General del Servicio Meteorológico Nacional | [官网](https://smn.cna.gob.mx) |
| Micronesia (Federated States of) | WSO Chuuk, FSM | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=159) |
| Monaco | Direction de l'Environnement | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=160) |
| Mongolia | National Agency for Meteorology and Environmental Monitoring of Mongolia | [官网](https://www.namem.gov.mn) |
| Montenegro | Institute of Hydrometeorology and Seismology | [官网](https://www.meteo.co.me) |
| Morocco | Direction de la Météorologie Nationale | [官网](https://www.marocmeteo.ma) |
| Mozambique | Instituto Nacional de Meteorologia | [官网](https://www.inam.gov.mz) |
| Myanmar | Department of Meteorology and Hydrology (DMH) | [官网](https://www.dmh.gov.mm) |
| Namibia | Namibia Meteorological Service | [官网](https://www.meteona.com) |
| Nauru | 未在WMO字段中列出 | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=206) |
| Nepal | Department of Hydrology and meteorology | [官网](https://www.dhm.gov.np/) |
| Netherlands (Kingdom of the) | Royal Netherlands Meteorological Institute | [官网](https://www.knmi.nl) |
| New Caledonia | Météo-France Regional Service New Caledonia, Wallis and Futuna | [官网](https://www.meteo.nc) |
| New Zealand | New Zealand National Meteorological Service | [官网](https://www.metservice.co.nz) |
| Nicaragua | Instituto Nicaraguense de Estudios Territoriales | [官网](https://www.ineter.gob.ni) |
| Niger | Direction de la Meteorologie nationale (DMN) | [官网](https://www.niger-meteo.ne) |
| Nigeria | Nigerian Meteorological Agency | [官网](https://www.nimet.gov.ng) |
| Niue | Niue Meteorological Service | [官网](https://informet.net/met/garry_004.htm) |
| North Macedonia | HydroMeteorological Service of Republic of North Macedonia | [官网](https://www.meteo.gov.mk/) |
| Norway | Norwegian Meteorological Institute | [官网](https://www.met.no) |
| Oman | Directorate General of Meteorology - Civil Aviation Authority | [官网](https://met.gov.om/) |
| Pakistan | Pakistan Meteorological Department | [官网](https://www.pmd.gov.pk) |
| Panama | IMHPA - Instituto de Meteorología e Hidrología de Panamá | [官网](https://www.imhpa.gob.pa/es/) |
| Papua New Guinea | Papua New Guinea Meteorological Service | [官网](https://www.pngmet.gov.pg) |
| Paraguay | Dirección de Meteorología e Hidrología (DMH) | [官网](https://www.meteorologia.gov.py) |
| Peru | Servicio Nacional de Meteorología e Hidrología del Perú | [官网](https://www.senamhi.gob.pe) |
| Philippines | Philippine Atmospheric Geophysical and Astronomical Services Administration | [官网](https://www.pagasa.dost.gov.ph) |
| Poland | Institute of Meteorology and Water Management | [官网](https://www.imgw.pl) |
| Portugal | Instituto Português do Mar e da Atmosfera | [官网](https://www.ipma.pt) |
| Portugal - Madeira | Instituto de Meteorologia | [官网](https://www.meteo.pt) |
| Qatar | Qatar Meteorology Department | [官网](https://qweather.gov.qa/Index.aspx) |
| Republic of Korea | Korea Meteorological Administration | [官网](https://web.kma.go.kr/eng/index.jsp) |
| Republic of Moldova | State Hydrometeorological Service | [官网](https://www.meteo.md) |
| Romania | National Meteorological Administration | [官网](https://www.inmh.ro) |
| Russian Federation | Russian Federal Service for Hydrometeorology and Environmental Monitoring | [官网](https://www.meteorf.ru) |
| Rwanda | Rwanda Meteorology Agency | [官网](https://www.meteorwanda.gov.rw) |
| Saint Lucia | Saint Lucia Meteorological Services | [官网](https://www.slumet.gov.lc) |
| Samoa | Samoa Meteorology Division | [官网](https://www.samet.gov.ws) |
| Sao Tome and Principe | Instituto Nacional de Meteorologia | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=78) |
| Saudi Arabia | National Center for Meteorology | [官网](https://ncm.gov.sa) |
| Senegal | Agence nationale de l'Aviation Civile et de la Météorologie (ANACIM) | [官网](https://www.anacim.sn) |
| Serbia | Republic Hydrometeorological Service of Serbia | [官网](https://www.meteo.rs) |
| Seychelles | Seychelles Meteorological Authority | [官网](https://www.meteo.gov.sc) |
| Sierra Leone | Sierra Leone Meteorological Agency | [官网](https://slmet.gov.sl) |
| Singapore | Meteorological Service Singapore | [官网](https://www.weather.gov.sg) |
| Slovakia | Slovak Hydrometeorological Institute | [官网](https://www.shmu.sk) |
| Slovenia | Slovenian Environment Agency | [官网](https://www.arso.gov.si) |
| Solomon Islands | Solomon Islands Meteorological Service | [官网](https://www.met.gov.sb) |
| Somalia | Somalia National Meteorological Agency | [官网](https://meteosomalia.so) |
| South Africa | South African Weather Service | [官网](https://www.weathersa.co.za) |
| South Sudan | South Sudan Meteorological Department | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=203) |
| Spain | Agencia Estatal de Meteorología | [官网](https://www.aemet.es) |
| Spain - Canary Islands | Agencia Estatal de Meteorología | [官网](https://www.aemet.es) |
| Spain - Ceuta | Agencia Estatal de Meteorología | [官网](https://www.aemet.es) |
| Spain - Melilla | Agencia Estatal de Meteorología | [官网](https://www.aemet.es) |
| Sri Lanka | National Meteorological Centre | [官网](https://www.meteo.gov.lk) |
| Sudan | Sudan Meteorological Authority | [官网](https://meteosudan.sd) |
| Suriname | Meteorological Service | [官网](https://www.meteosur.sr) |
| Sweden | Swedish Meteorological and Hydrological Institute (SMHI) | [官网](https://www.smhi.se) |
| Switzerland | MeteoSwiss - Federal Office of Meteorology and Climatology | [官网](https://www.meteoswiss.ch/web/en/weather.html) |
| Syrian Arab Republic | Ministry of Defence Meteorological Department | [官网](https://www.meteo.sy) |
| Tajikistan | Agency for Hydrometeorlogy of the Republic of Tajikistan | [官网](https://www.meteo.tj) |
| Thailand | Thai Meteorological Department | [官网](https://www.tmd.go.th) |
| Timor-Leste | Dirrecão Nacional Meteorologia e Geofisica | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=204) |
| Togo | Agence Nationale de la Météorologie du Togo | [官网](https://www.anamet-togo.com) |
| Tonga | Tonga Meteorological Service | [官网](https://www.met.gov.to) |
| Trinidad and Tobago | Trinidad and Tobago Meteorological Service | [官网](https://www.metoffice.gov.tt) |
| Tunisia | Institut National de la Meteorologie | [官网](https://www.meteo.tn) |
| Turkmenistan | Administration of Hydrometeorology | [WMO国家页](https://worldweather.wmo.int/en/country.html?countryCode=111) |
| Tuvalu | Tuvalu Meteorological Service | [官网](https://informet.net/met/garry_004.htm) |
| Türkiye | Turkish State Meteorological Service | [官网](https://www.mgm.gov.tr) |
| UK - Bermuda | Bermuda Weather Service | [官网](https://www.weather.bm) |
| UK - Guernsey | Meteorological Observatory, Guernsey Airport | [官网](https://www.metoffice.gov.gg) |
| UK - Isle of Man | Isle of Man Government | [官网](https://www.gov.im/weather/) |
| UK - Jersey | Jersey Meteorological Department | [官网](https://www.jerseymet.gov.je) |
| Uganda | Uganda National Meteorological Authority | [官网](https://www.unma.go.ug) |
| Ukraine | Ukrainian Hydrometeorological Center | [官网](https://www.meteo.gov.ua) |
| United Arab Emirates | The National Center of Meteorology | [官网](https://www.ncm.gov.ae) |
| United Kingdom of Great Britain and Northern Ireland | Met Office | [官网](https://www.metoffice.gov.uk) |
| United Republic of Tanzania | Tanzania Meteorological Agency | [官网](https://www.meteo.go.tz) |
| United States of America | National Weather Service | [官网](https://www.nws.noaa.gov/) |
| Uruguay | Instituto Uruguayo de Meteorologia | [官网](https://www.meteorologia.com.uy) |
| Uzbekistan | Uzhydromet | [官网](https://hydromet.uz) |
| Vanuatu | Vanuatu Meteorology and Geo-hazards Department | [官网](https://www.meteo.gov.vu/) |
| Venezuela, Bolivarian Republic of | Instituto Nacional de Meteorología e Hidrología (INAMEH) | [官网](https://www.inameh.gob.ve) |
| Viet Nam | Viet Nam Meteorological and Hydrological Administration | [官网](https://www.nchmf.gov.vn) |
| Yemen | Civil Aviation & Met Authority - Yemen meteorological Service | [官网](https://www.yms.gov.ye) |
| Zambia | Zambia Meteorological Department (ZMD) | [官网](https://www.zmd.gov.zm) |
| Zimbabwe | Meteorological Services Department | [官网](https://www.weatherzw.org.zw) |

## 编写日期与来源

- 文档生成日期：2026-09-01
- 主要来源：[WMO World Weather Information Service](https://worldweather.wmo.int/)、[WMO Members](https://wmo.int/about/wmo-members)、[Open-Meteo](https://open-meteo.com/)、[Open-Meteo Weather Forecast API](https://open-meteo.com/en/docs)
- WMO 说明其成员维护各自气象服务；Open-Meteo 提供全球天气预报、历史天气、温度、湿度、天气码等统一 API 字段。使用时仍需实时核验最新页面和条款。
