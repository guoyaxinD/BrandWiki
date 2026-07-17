---
name: brand-review-report
description: Generate interactive HTML monthly business review reports from Excel data with Chart.js visualizations, tab navigation, zoom modals, editable text, and localStorage persistence. Use when user provides brand/business Excel data and asks for a visual review report.
version: 1.4.0
install_method: upload
---

# Brand Monthly Review HTML Report Generator

## Overview

从品牌经营Excel数据（含多Sheet：生意、流失竞对、性别年龄段、竞对生意、热销菜品、CRM等）生成交互式HTML月度复盘报告。报告采用纯可视化（无表格）、Tab分模块、支持图表放大/隐藏/文字编辑/持久化。

**BrandWiki 联动**：生成报告前自动 Recall 品牌历史诊断（如有），让诊断文字包含环比变化和趋势判断；报告生成后自动提取核心结论，提议 Ingest 存入 Wiki。详见 §1.5 和 §11。

**默认全维度诊断，不进行意图问询**——直接读取Excel并生成覆盖全部维度的报告。若用户在初始需求中明确了聚焦方向（如"重点看会员深耕"、"给服务商作战清单"），按 §10 表格调整文案侧重；否则一律采用"全维度均衡诊断 + 通用行动建议"。

## Steps

### 1. 数据提取（Python）

```python
# -*- coding: utf-8 -*-
import pandas as pd, json, sys, io

# Windows GBK编码处理
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

# 必须指定engine='openpyxl'（xlrd不支持xlsx）
xls = pd.ExcelFile(r'path\to\file.xlsx', engine='openpyxl')

# 逐sheet读取，转为JSON结构
data = {}
for name in xls.sheet_names:
    df = pd.read_excel(xls, sheet_name=name, header=None)
    data[name] = df.values.tolist()

# 写入UTF-8 JSON文件（不要直接print含中文的内容）
with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False)
```

### 1.5 BrandWiki Recall（报告前回忆历史诊断）

在数据提取完成后、HTML 生成前执行。目的是让报告诊断文字有历史纵深，而非孤立描述当期数据。

```
步骤 0：读取 Wiki 路径配置
        执行：cat ~/.qoderworkcn/brand-wiki-path
        将结果记为 WIKI_ROOT（如配置文件不存在，默认 ~/BrandWiki/）

步骤 1：推断品牌名
        - 优先从用户对话中提取（如"海底捞的报告"）
        - 其次从 Excel 文件名推断（如"海底捞_202607.xlsx"）
        - 如无法确定，询问用户

步骤 2：检查 {WIKI_ROOT}/brands/{品牌名}/ 目录是否存在
        - 如不存在：这是首次分析该品牌，跳过 Recall，正常生成报告
        - 如存在：继续步骤 3

步骤 3：读取以下文件（用 Read 工具）
        - _dashboard.md  → 历史核心指标趋势
        - people.md     → 历史用户经营诊断结论
        - products.md   → 历史商品分析结论
        - store.md      → 历史门店/渠道诊断结论
        - solutions.md  → 已有方案及执行状态

步骤 4：将读取到的历史信息作为上下文，注入后续 HTML 生成中
        - 诊断文字中融入环比分析（如"较上期+5%"/"连续3期下滑"）
        - 方案建议中引用上期方案及其状态（如"上期建议的XX方案本期数据未见改善"）
        - 优劣势判断引用多期数据支撑，增强确定性
```

**注意**：如果品牌目录存在但所有页面都是空模板（首次入库后未填充），等同于无历史记录，正常生成即可。

### 2. HTML报告结构

```
单文件HTML，包含：
├── <head>: Chart.js 4.4.1 CDN + chartjs-plugin-datalabels 2.2.0 CDN + 内嵌CSS
├── <body>:
│   ├── .nav（横排Tab按钮）
│   ├── .section#overview（经营概览）
│   ├── .section#trend（生意趋势）
│   ├── .section#portrait（用户画像）
│   ├── .section#products（热销菜品）
│   ├── .section#crm（CRM经营）
│   ├── .section#compete（竞对分析）
│   ├── .section#trust（TRUST模型）
│   └── .section#summary（诊断总结）
└── <script>: Chart.js初始化 + Tab切换 + 各Tab图表 + 交互功能
```

### 3. Chart.js 初始化（必须在所有图表创建之前）

```javascript
Chart.register(ChartDataLabels);
Chart.defaults.font.family = '-apple-system,"PingFang SC","Microsoft YaHei",sans-serif';
Chart.defaults.font.size = 13;
Chart.defaults.plugins.datalabels = { display: false }; // 默认关闭，逐图开启
```

### 4. Tab懒加载模式

```javascript
const tabInited = {};
const initTab = {};

function showTab(id, btn) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  btn.classList.add('active');
  if (!tabInited[id]) { tabInited[id] = true; initTab[id] && initTab[id](); }
}

// 每个Tab的图表初始化函数在initTab中注册
```

### 5. 纯可视化报告（无表格）

**强制规则**：HTML 中不应出现 `<table>` 标签。所有数据以 Chart.js 图表（柱状图、折线图、饼图、雷达图、环形图等）呈现。

### 6. Zoom 放大功能

点击任意图表可弹出全屏浮层显示大尺寸版本：

```javascript
function openZoom(chartConfig) {
  const wrap = document.getElementById('zoom-wrap');
  wrap.style.display = 'flex';
  wrap.innerHTML = '<canvas id="zoomCanvas"></canvas>';
  // 使用 cloneDeep 深拷贝配置，重置尺寸
  const cfg = cloneDeep(chartConfig);
  const ctx = document.getElementById('zoomCanvas').getContext('2d');
  new Chart(ctx, cfg);
}
```

### 7. 图表隐藏/显示 + localStorage 持久化

每个图表右上角有 × 按钮可隐藏，隐藏状态存 localStorage，刷新页面后保持：

```javascript
function toggleChart(chartId, btn) {
  const container = document.getElementById(chartId);
  const hidden = JSON.parse(localStorage.getItem('hiddenCharts') || '{}');
  if (container.style.display === 'none') {
    container.style.display = 'block';
    btn.textContent = '×';
    delete hidden[chartId];
  } else {
    container.style.display = 'none';
    btn.textContent = '＋';
    hidden[chartId] = true;
  }
  localStorage.setItem('hiddenCharts', JSON.stringify(hidden));
}
```

### 8. 诊断文字编辑 + localStorage 持久化

诊断总结部分的文字可点击编辑，使用 contenteditable + localStorage 保存：

```javascript
// 所有 .editable-text 元素点击可编辑
// blur 事件触发时保存到 localStorage
// 刷新后从 localStorage 恢复
```

### 9. 诊断总结Tab结构

最后一Tab为"诊断总结"，包含以下卡片：
- **亮点**（可编辑、可删除、可添加）
- **问题**（可编辑、可删除、可添加）
- **行动建议**（可编辑、可删除、可添加）
- **恢复默认按钮**

### 10. 意图适配（仅当用户主动说明方向时启用）

若用户在初始需求中明确了分析聚焦方向，按以下表格调整各Tab内的诊断文案侧重：

| 用户意图 | 概览诊断文案侧重 | 趋势诊断文案侧重 | 用户画像侧重 | 热销品侧重 | CRM侧重 | 竞对侧重 | TRUST侧重 | 诊断总结"行动建议"卡 |
|---------|----------------|----------------|------------|----------|--------|--------|---------|---------------------|
| 诊断总结"行动建议"卡 O1-O4 | 通用四维OKR | 全部围绕会员漏斗与LTV | 全部围绕竞品差异化+菜品缺口 | 全部围绕定价与补贴优化 | 全部围绕扩店节奏与效率 |

`action_role` 决定"行动建议"卡的**语言颗粒度与主语**（同样仅当用户主动说明时启用，默认使用"通用诊断结论"）：
- **OKR 拆解**：`O1: [目标] KR1/KR2/KR3` 三段式；给出季度末达成数字。
- **服务商作战清单**：动词开头 + 抓手动作，例如"上线XX会员唤醒 push、每周复盘一次转化率"；主语是服务商。
- **平台侧策略输入**：以"建议平台..."开头，聚焦产品能力/资源位/补贴机制。
- **通用诊断结论**（默认）：不点名执行方，纯业务结论。

**关键约束**：不要主动向用户提问 focus / action_role。用户没说就走默认。

### 11. BrandWiki Ingest（报告完成后提取结论入库）

HTML 报告生成并输出给用户后执行。目的是将本次报告的核心结论沉淀到 Wiki，供后续报告 Recall 使用。

```
步骤 0：读取 Wiki 路径配置
        执行：cat ~/.qoderworkcn/brand-wiki-path
        将结果记为 WIKI_ROOT（如配置文件不存在，默认 ~/BrandWiki/）

步骤 1：存档报告 HTML
        - 将生成的 HTML 报告复制到 {WIKI_ROOT}/raw/reports/
        - 文件名格式：{日期}_{品牌名}_review.html
        - 文件操作：优先用 Write 工具（如 BrandWiki 在工作区内），否则用 Bash 命令

步骤 2：提取各维度核心结论
        从本次报告中提取以下信息：
        - 大盘：核心指标摘要（GMV/订单量/客单价/会员活跃率/复购率等关键数字）
        - 人维度：用户经营的关键发现（1-2句话）
        - 品维度：商品分析的关键发现（1-2句话）
        - 店维度：门店/渠道的关键发现（1-2句话）
        - 方案建议：本次提出的行动建议及优先级

步骤 3：展示摘要卡片供用户确认

        "报告已生成。提取到以下核心结论：

        [品牌X] 2026年7月复盘
        ━━━━━━━━━━━━━━━━
        大盘：GMV xx万（环比+5%），客单价 ¥xx（环比-2%）
        人：{核心发现}
        品：{核心发现}
        店：{核心发现}
        方案：{建议摘要}

        存入 Wiki？"

步骤 4：用户确认后，执行 Wiki 写入
        - 如品牌目录不存在：创建完整品牌目录结构（参照 brand-wiki 技能）
        - 更新对应维度页面（刷新"当前结论"、追加"历史演变"行）
        - 更新 _dashboard.md（追加当期指标数据行）
        - 更新 _meta.md（追加时间线记录）
        - 追加 _log.md（操作记录）
        - 更新 solutions.md（如有新方案建议）

步骤 5：如本次报告产生了跨品牌的通用洞察，单独提议是否存入 domain/
```

**文件操作规则（跨平台）**：优先使用 Write/Edit 工具（需 BrandWiki 目录被选为工作文件夹）。如不在工作区内，macOS 用 cp/cat/mkdir，Windows PowerShell 用 copy/Get-Content/New-Item。写入内容遵循 {WIKI_ROOT}/SCHEMA.md 中的页面模板。

## Pitfalls

- **cloneDeep不能用hasOwnProperty**：Chart.js内部用 `Object.create(null)` 创建对象，无原型方法。必须用 `Object.keys()` 遍历。
- **cloneDeep必须跳过特殊对象**：HTMLElement、CanvasGradient、CanvasPattern 不能深拷贝，直接返回引用。
- **不要包装Chart构造函数**：不要用Proxy或函数包装器拦截 `new Chart()`，会破坏内部行为。用官方 `Chart.getChart(canvas)` API获取实例。
- **Tab懒加载时机**：图表必须在对应section可见后再创建（`display:none`时canvas尺寸为0）。
- **Windows Python编码**：必须 `engine='openpyxl'`（xlrd不支持xlsx）；不要直接print含中文内容（GBK报错），写文件用 `encoding='utf-8'`。
- **datalabels formatter丢失**：cloneDeep会保留函数引用，但需要显式从原始config拷贝dataset级和options级的formatter。
- **Zoom时必须重建canvas DOM**：`wrap.innerHTML = '<canvas id="zoomCanvas"></canvas>'` 确保canvas干净，否则残留的Chart实例会冲突。
- **不做意图问询**：本技能默认不用 AskUserQuestion 询问 focus / action_role，直接按全维度生成；只有当用户在初始需求里主动说明方向时才按 §10 调整。

## Verification

1. 打开HTML文件，逐个Tab切换确认图表渲染正常
2. 点击任意图表确认弹出放大浮层，图表动态可交互
3. 点击×隐藏图表，刷新页面确认隐藏状态保持
4. 编辑诊断文字，刷新确认修改保持
5. 诊断总结Tab：点击亮点/问题/建议条目可编辑文字，清空后按Delete确认条目被移除，刷新后保持
6. 点击"恢复默认"确认所有状态重置
7. 经营概览（首个Tab）的图表放大后必须正常显示（历史高频bug点）
