# BrandWiki — 品牌经营知识库

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](BrandWiki/SCHEMA.md)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows-lightgrey)](#)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> 📘 一个与日常业务对话同步增长的品牌经营知识库系统，专为 [QoderWork](https://www.qoderwork.cn) AI 工作平台设计。

**BrandWiki** 让每一次品牌分析、每份复盘报告、每次业务讨论都能沉淀为结构化知识。下次生成报告时，AI 会自动 Recall 历史诊断，让分析有纵深、建议有依据、判断有趋势。

---

## ✨ 核心能力

| 能力 | 说明 |
|------|------|
| 🔄 **自动 Recall** | 生成报告或回答业务问题时，AI 自动读取历史诊断作为上下文 |
| 📥 **智能 Ingest** | 对话尾声静默评估，有价值的业务洞察自动提议入库 |
| 📊 **报告联动** | `brand-review-report` 技能生成 HTML 报告时，前后自动 Recall + Ingest |
| 🏥 **健康检查** | 定期检测空页面、未关联方案、过期结论等质量问题 |
| 🌐 **跨品牌知识** | 支持将通用方法论、行业基准沉淀到领域层（需人工确认） |

---

## 🏗️ 架构概览

```
BrandWiki-Package/
├── BrandWiki/                  # 知识库模板文件
│   ├── SCHEMA.md               # 行为规则 + 页面模板（AI 遵循的"宪法"）
│   ├── _log.md                 # 全局操作日志
│   └── domain/
│       └── _index.md           # 领域知识索引
│
├── skills/                     # QoderWork AI 技能
│   ├── brand-wiki/             # 知识库维护技能（v1.1.0）
│   │   └── SKILL.md
│   └── brand-review-report/    # HTML 报告生成技能（v1.4.0）
│       └── SKILL.md
│
├── install.sh                  # macOS/Linux 一键安装脚本
├── install.bat                 # Windows 一键安装脚本
├── agents-rules.txt            # AI 行为规则（写入 AGENTS.md）
├── brand-wiki-path             # 路径配置模板
├── BrandWiki-操作手册.md        # 完整操作手册
└── README.md
```

### 知识库运行时目录结构

```
{WIKI_ROOT}/
├── SCHEMA.md                   # 行为规则与页面模板
├── _log.md                     # 操作日志（只追加）
│
├── brands/                     # 品牌层
│   └── {品牌名}/
│       ├── _meta.md            # 品牌档案 + 时间线
│       ├── _dashboard.md       # 核心指标趋势
│       ├── people.md           # 人：用户/会员/复购
│       ├── products.md         # 品：商品/菜品/产品
│       ├── store.md            # 店：门店/渠道/区域
│       └── solutions.md        # 方案（关联具体痛点）
│
├── domain/                     # 领域层（跨品牌通用知识）
│   ├── frameworks/             # 分析框架与方法论
│   ├── patterns/               # 经验证的有效打法
│   ├── benchmarks/             # 行业基准与对标数据
│   └── concepts/               # 业务概念与术语
│
└── raw/                        # 原始文件存档
    ├── uploads/                # 上传文档原件
    └── reports/                # 生成的 HTML 报告
```

---

## 🚀 快速开始

### 方式一：一键安装（推荐）

**macOS / Linux**：
```bash
chmod +x install.sh && ./install.sh
```

**Windows**：
```
双击运行 install.bat
```

### 方式二：手动安装

1. **安装技能**：将 `skills/brand-wiki/SKILL.md` 和 `skills/brand-review-report/SKILL.md` 拖入 QoderWork 窗口保存
2. **配置路径**：在 `~/.qoderworkcn/brand-wiki-path` 中写入存储路径（例如 `~/BrandWiki/`）
3. **复制模板**：将 `BrandWiki/` 目录内容复制到配置的路径下
4. **写入规则**：将 `agents-rules.txt` 内容追加到项目的 `AGENTS.md` 中

---

## 📖 使用方式

| 你说的话 | AI 做的事 |
|---------|----------|
| "存入 Wiki" | 将本次对话结论入库 |
| "查 Wiki" / "Wiki 里有什么" | 检索展示相关知识 |
| "检查 Wiki" | 执行健康检查 |
| "把这份报告存入 Wiki"（附文件）| 解析文档并提议入库 |
| 使用 brand-review-report 技能 | 自动 Recall → 生成报告 → 自动 Ingest |
| "XX品牌最近怎么样" | 自动读取 Wiki 回答 |

---

## 🔧 技术说明

- **平台**：基于 QoderWork AI 工作平台
- **跨平台**：完整支持 macOS 和 Windows，路径通过配置文件动态读取
- **报告技能**：使用 Chart.js 4.4.1 生成交互式 HTML 报告（含 Tab 切换、图表放大、文字编辑、localStorage 持久化）
- **知识格式**：Markdown + YAML frontmatter，兼容 Obsidian 等 Markdown 编辑器

---

## 📄 版本信息

| 组件 | 版本 | 日期 |
|------|------|------|
| BrandWiki Schema | 1.0.0 | 2026-07-16 |
| brand-wiki 技能 | 1.1.0 | 2026-07-16 |
| brand-review-report 技能 | 1.4.0 | 2026-07-16 |

---

## 👥 同事安装指南

将以下内容发给同事：

1. 安装两个技能文件，拖入 QoderWork 窗口保存
2. 创建 `~/.qoderworkcn/brand-wiki-path` 配置文件，写入存储路径
3. 将 `BrandWiki/` 初始目录复制到目标路径
4. 在项目 `AGENTS.md` 中追加 `agents-rules.txt` 的规则内容
5. （推荐）将 BrandWiki 文件夹选为 QoderWork 工作文件夹

---

## 📝 License

MIT
