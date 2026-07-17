---
name: brand-wiki
description: BrandWiki 品牌知识库维护技能。在每次对话中自动评估是否有值得沉淀的业务知识，支持三条入库路径（对话洞察/上传文档/报告提取）和两条出口（报告前回忆/问答时检索）。触发词：存入Wiki、Wiki入库、更新Wiki、查Wiki。当使用 brand-review-report 技能生成报告时自动联动。
version: 1.1.0
---

# BrandWiki — 品牌知识库维护技能

## 概述

BrandWiki 是一个持续积累的品牌经营知识库。它的核心理念是：每次对话、每份报告、每个业务讨论都能沉淀为结构化知识，让后续的报告生成更精准、业务问答更有深度。

本技能定义了 Wiki 的维护流程，包括 Ingest（入库）、Recall（调取）和 Lint（健康检查）三个核心操作。

**行为规则文件**：`{WIKI_ROOT}/SCHEMA.md`（目录结构、页面模板、质量标准）

## 路径配置（跨平台）

BrandWiki 的实际存储路径由配置文件决定，不硬编码，支持 macOS 和 Windows。

```
步骤 1：读取路径配置
        执行：cat ~/.qoderworkcn/brand-wiki-path
        该文件只有一行，内容为 BrandWiki 根目录的绝对路径
        例如 macOS：~/BrandWiki/
             Windows：D:\BrandWiki\

步骤 2：将读取到的路径记为 WIKI_ROOT，后续所有操作均使用此路径

步骤 3：如配置文件不存在，使用默认路径 ~/BrandWiki/，并自动创建该配置文件
```

**首次设置（新同事/新设备）**：
- macOS：默认 `~/BrandWiki/`，无需额外配置
- Windows：创建 `~/.qoderworkcn/brand-wiki-path` 文件，写入想要的路径（如 `D:\BrandWiki\`），然后在该路径下初始化目录结构

**文件操作规则（跨平台）**：
- 优先使用 QoderWork 的 Write/Edit 工具操作 Wiki 文件（要求 BrandWiki 目录被选为工作文件夹）
- 如 BrandWiki 不在工作区内，回退到 Bash 命令（macOS 用 cp/cat/mkdir，Windows PowerShell 用 copy/type/mkdir）
- 建议将 BrandWiki 目录选为 QoderWork 工作文件夹，确保 Write/Edit 可用，跨平台兼容性最佳

## 核心操作

### 操作一：Ingest（入库）

Ingest 有三条入口路径，流程统一：**评估 → 提议 → 确认 → 写入**。

#### 入口 A：对话洞察

**触发时机**：对话尾声，AI 静默评估本次对话是否产生了值得入库的业务知识。

**判断标准**（满足任一即入库）：
1. 包含新的业务事实或分析判断（非纯操作指令）
2. 对未来同品牌/同话题的对话有参考价值
3. 与 Wiki 已有知识矛盾或形成补充

**不入库的情况**：纯操作指令（改颜色/调格式/导出文件）、一次性信息查询、无结论的闲聊。

**执行流程**：

```
步骤 1：对话尾声，AI 静默判断是否满足入库标准
步骤 2：如满足，生成简短摘要卡片：

  "本次对话涉及：
   - [品牌X] 人维度：{结论摘要}
   - [品牌X] 品维度：{结论摘要}
   存入 Wiki？"

步骤 3：用户确认（全部/部分/跳过）
步骤 4：执行文件写入（见"写入流程"）
```

**关键约束**：不要每次都问"要不要存Wiki"。只在确实有价值时才提议，避免打扰用户。

#### 入口 B：上传文档

**触发时机**：用户上传报告、文档、截图等，要求 AI 阅读和分析时。

**执行流程**：

```
步骤 1：阅读并理解上传文档的全部内容
步骤 2：提取关键发现和结论
步骤 3：将原始文件存到 {WIKI_ROOT}/raw/uploads/（保留原件）
        文件名格式：{日期}_{品牌名}_{简要描述}.{原扩展名}
步骤 4：生成摘要卡片供用户确认：

  "文档已存档。提取到以下关键知识：
   - [品牌X] {维度}：{结论}
   - [品牌X] {维度}：{结论}
   - [跨品牌] {通用知识}（可选，需单独确认）
   存入 Wiki？"

步骤 5：用户确认后，执行文件写入
```

#### 入口 C：报告提取（与 brand-review-report 技能联动）

**触发时机**：brand-review-report 技能完成 HTML 报告生成后。

**执行流程**：

```
步骤 1：报告 HTML 生成完成后，将报告存档到 {WIKI_ROOT}/raw/reports/
        文件名格式：{日期}_{品牌名}_review.html
步骤 2：从报告中提取各维度核心结论：
        - 经营大盘：核心指标变化摘要
        - 人维度：用户经营的关键发现
        - 品维度：商品/产品的关键发现
        - 店维度：门店/渠道的关键发现
        - 方案建议：本次提出的行动建议
步骤 3：展示摘要卡片供用户确认
步骤 4：确认后，执行文件写入
```

#### 写入流程（三条入口共用）

```python
# 以下为伪代码，描述文件操作逻辑

WIKI_ROOT = "{WIKI_ROOT}"  # 从 ~/.qoderworkcn/brand-wiki-path 读取

def ingest(brand_name, findings, source_type):
    brand_dir = f"{WIKI_ROOT}/brands/{brand_name}"

    # 1. 确保品牌目录存在，否则创建全套模板文件
    if not exists(brand_dir):
        create_directory(brand_dir)
        create_from_template(f"{brand_dir}/_meta.md",     "_meta")
        create_from_template(f"{brand_dir}/_dashboard.md", "_dashboard")
        create_from_template(f"{brand_dir}/people.md",     "people")
        create_from_template(f"{brand_dir}/products.md",   "products")
        create_from_template(f"{brand_dir}/store.md",      "store")
        create_from_template(f"{brand_dir}/solutions.md",  "solutions")

    # 2. 按维度更新页面（追加历史演变行、刷新当前结论）
    for dimension, content in findings["dimensions"].items():
        page = f"{brand_dir}/{dimension}.md"
        append_to_history(page, content["summary"])
        update_current_conclusion(page, content["conclusion"])
        if content.get("new_solution"):
            append_to_solutions(f"{brand_dir}/solutions.md", content["new_solution"])

    # 3. 更新指标看板（如有新数据）
    if findings.get("metrics"):
        append_metrics_row(f"{brand_dir}/_dashboard.md", findings["metrics"])

    # 4. 更新品牌档案时间线
    append_timeline(f"{brand_dir}/_meta.md", findings["summary"])

    # 5. 追加操作日志
    append_log(f"{WIKI_ROOT}/_log.md", f"INGEST | {brand_name} | {findings['summary']} | 来源：{source_type}")
```

### 操作二：Recall（调取）

Recall 不需要用户触发。AI 在生成报告或回答业务问题时自动执行。

#### 出口 A：报告生成时的上下文注入

在 brand-review-report 技能执行 HTML 生成之前执行：

```
步骤 1：识别当前品牌名（从文件名/用户输入/数据内容推断）
步骤 2：检查 {WIKI_ROOT}/brands/{品牌名}/ 是否存在
步骤 3：如存在，读取以下文件：
        - _dashboard.md → 获取历史指标趋势
        - people.md → 获取历史用户诊断
        - products.md → 获取历史商品诊断
        - store.md → 获取历史门店诊断
        - solutions.md → 获取已有方案及其状态
步骤 4：将读取的内容作为上下文，注入后续的诊断分析和文案生成中
步骤 5：如不存在，正常生成报告（首次分析该品牌）
```

**Recall 如何改善报告质量**：
- 诊断文字从"会员活跃率是32%"变为"会员活跃率从上期35%降至32%，连续两期下滑"
- 方案建议从"建议加强会员运营"变为"上期建议的唤醒push策略在数据上未见效果，建议更换为XX方案"
- 优势劣势判断越来越确定，因为有多期数据支撑

#### 出口 B：业务问答时

用户提出业务相关问题时自动执行：

```
步骤 1：识别问题涉及的品牌和维度
步骤 2：读取对应品牌页面
步骤 3：读取 domain/ 中相关知识（通过 domain/_index.md 定位）
步骤 4：结合 Wiki 知识 + 实时分析给出回答
```

### 操作三：Lint（健康检查）

可手动触发（"检查Wiki"）或通过定时任务定期执行。

**检查项目**：

```
1. 索引一致性：_log.md 中的记录是否与 Wiki 页面实际内容对应
2. 空页面检测：是否有品牌的维度页面从未填充过实质内容
3. 方案关联检查：solutions.md 中每条方案是否关联了至少一个痛点
4. 结论完整性：每个维度页面的"当前结论"段落是否为空
5. 过期标记：是否有标记为"临时"或"待验证"的结论超过 30 天未更新
6. 孤立页面：是否有页面没有被任何其他页面引用
```

**输出格式**：

```
Wiki 健康检查报告（{日期}）
━━━━━━━━━━━━━━━━━━━━━━
品牌数量：{N}
页面总数：{N}
操作记录：{N} 条

发现问题：
  ⚠️ {品牌X}/solutions.md: 2条方案未关联痛点
  ⚠️ {品牌Y}/store.md: 当前结论为空
  ℹ️ {品牌Z}/people.md: 30天未更新

建议操作：
  1. 补充 {品牌X} 方案的痛点关联
  2. 更新 {品牌Y} 的门店诊断结论
```

## 跨品牌知识（domain/）入库规则

**重要**：domain/ 下的知识**必须经过用户确认**才能入库，不自动存储。

**触发条件**：
- AI 在分析过程中发现了可复用的跨品牌规律
- 用户在对话中讨论了行业通用方法论
- 上传的文档包含行业基准数据

**提议格式**：

```
"发现一条跨品牌经验：
 [{知识摘要}]
 来源：{品牌X}的实践 / {某文档}
 存入领域知识库？"
```

**入库后**：更新 `domain/_index.md` 添加条目。

## 与 brand-review-report 技能的集成点

brand-review-report 技能的流程改造（在生成报告时手动执行以下步骤）：

```
原流程：读Excel → 生成HTML → 结束

改造后流程：
1. 读Excel数据（原 Step 1）
2. ★ Recall：读取品牌 Wiki 历史数据（本技能）
3. 生成HTML（原 Step 2-9），诊断文字中融入历史对比
4. ★ Ingest：提取报告结论，提议存入 Wiki（本技能）
5. 结束
```

**联动说明**：brand-review-report 技能（v1.4.0+）已在 SKILL.md 中内置 §1.5 Recall 和 §11 Ingest 步骤，生成报告时会自动执行 Wiki 回忆和结论提取，无需依赖外部规则提醒。路径从 `~/.qoderworkcn/brand-wiki-path` 配置文件读取，支持跨平台。

## Pitfalls

- **不要过度入库**：只在确实有业务价值时才提议，避免每次对话都弹确认框打扰用户
- **历史演变只追加不删除**：即使旧结论被推翻，保留它并标注变化，不要删除旧行
- **文件操作跨平台**：优先使用 Write/Edit 工具（需 BrandWiki 在工作区内）；如不在工作区，macOS 用 cp/cat/mkdir，Windows PowerShell 用 copy/Get-Content/New-Item。路径从 `~/.qoderworkcn/brand-wiki-path` 读取，不硬编码
- **品牌名推断**：从 Excel 文件名、用户对话内容、数据表头等多个信号推断品牌名，不确定时询问
- **维度页面冲突**：一次 Ingest 可能涉及多个维度，确保每个维度页面独立更新，不覆盖其他维度的内容
- **首次入库需建全套文件**：新品牌第一次入库时，必须创建所有 6 个模板文件（_meta/_dashboard/people/products/store/solutions），不能只建涉及的那个

## Verification

1. 对一个测试品牌执行完整的 Ingest 流程，确认所有文件正确创建
2. 执行 Recall 确认可正确读取品牌历史数据
3. 执行 Lint 确认能检测到空页面和未关联方案
4. 验证文件写入到 {WIKI_ROOT} 正确路径下（从配置文件读取的实际路径）
5. 确认 _log.md 追加格式符合规范
