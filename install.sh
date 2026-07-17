#!/bin/bash
# ============================================
# BrandWiki 一键安装脚本
# 双击运行即可完成所有配置
# ============================================

set -e

echo "=========================================="
echo "  BrandWiki 一键安装"
echo "=========================================="
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---- 1. 配置路径 ----
echo "[1/4] 配置 BrandWiki 路径..."

CONFIG_FILE="$HOME/.qoderworkcn/brand-wiki-path"
DEFAULT_PATH="$HOME/BrandWiki/"

if [ -f "$CONFIG_FILE" ]; then
    EXISTING_PATH=$(cat "$CONFIG_FILE")
    echo "  已有配置：$EXISTING_PATH"
    echo "  是否保留现有路径？(y/n，直接回车保留)"
    read -r KEEP
    if [ "$KEEP" != "n" ] && [ "$KEEP" != "N" ]; then
        WIKI_ROOT="$EXISTING_PATH"
        echo "  ✓ 保留现有路径：$WIKI_ROOT"
    else
        echo "  请输入 BrandWiki 存放路径（直接回车使用默认 $DEFAULT_PATH）："
        read -r CUSTOM_PATH
        if [ -z "$CUSTOM_PATH" ]; then
            WIKI_ROOT="$DEFAULT_PATH"
        else
            WIKI_ROOT="$CUSTOM_PATH"
        fi
        echo "$WIKI_ROOT" > "$CONFIG_FILE"
        echo "  ✓ 路径已配置：$WIKI_ROOT"
    fi
else
    echo "$DEFAULT_PATH" > "$CONFIG_FILE"
    WIKI_ROOT="$DEFAULT_PATH"
    echo "  ✓ 使用默认路径：$WIKI_ROOT"
fi

# 展开 ~ 为实际路径
WIKI_ROOT="${WIKI_ROOT/#\~/$HOME}"

# ---- 2. 创建目录结构 ----
echo ""
echo "[2/4] 创建 BrandWiki 目录结构..."

mkdir -p "$WIKI_ROOT/brands"
mkdir -p "$WIKI_ROOT/domain/frameworks"
mkdir -p "$WIKI_ROOT/domain/patterns"
mkdir -p "$WIKI_ROOT/domain/benchmarks"
mkdir -p "$WIKI_ROOT/domain/concepts"
mkdir -p "$WIKI_ROOT/raw/uploads"
mkdir -p "$WIKI_ROOT/raw/reports"

cp "$SCRIPT_DIR/BrandWiki/SCHEMA.md" "$WIKI_ROOT/SCHEMA.md"

# 只在 _log.md 不存在时复制初始版本
if [ ! -f "$WIKI_ROOT/_log.md" ]; then
    cp "$SCRIPT_DIR/BrandWiki/_log.md" "$WIKI_ROOT/_log.md"
fi

# 只在 _index.md 不存在时复制初始版本
if [ ! -f "$WIKI_ROOT/domain/_index.md" ]; then
    cp "$SCRIPT_DIR/BrandWiki/domain/_index.md" "$WIKI_ROOT/domain/_index.md"
fi

echo "  ✓ 目录结构已创建"

# ---- 3. 写入 AGENTS.md 规则 ----
echo ""
echo "[3/4] 写入 AI 行为规则..."

AGENTS_FILE="$HOME/.qoderworkcn/awareness/main/AGENTS.md"
mkdir -p "$(dirname "$AGENTS_FILE")"

# 检查是否已有 BrandWiki 规则
if [ -f "$AGENTS_FILE" ] && grep -q "BrandWiki 知识库意识规则" "$AGENTS_FILE"; then
    echo "  ✓ AGENTS.md 中已存在 BrandWiki 规则，跳过"
else
    # 如果 AGENTS.md 不存在，创建基础结构
    if [ ! -f "$AGENTS_FILE" ]; then
        echo "# AGENTS.md - 工作手册" > "$AGENTS_FILE"
        echo "" >> "$AGENTS_FILE"
    fi

    # 追加 BrandWiki 规则
    cat >> "$AGENTS_FILE" << 'RULES'

## BrandWiki 知识库意识规则

BrandWiki 是持续积累的品牌经营知识库，路径从 `~/.qoderworkcn/brand-wiki-path` 配置文件读取（记为 WIKI_ROOT）。每次对话遵循以下规则：

**读取（Recall）**：回答任何业务相关问题或生成报告前，先检查 `{WIKI_ROOT}/brands/{品牌名}/` 是否有相关知识页面，有则读取作为上下文。此步骤自动执行，无需用户指示。

**评估（Ingest）**：对话尾声，静默评估本次对话是否产生了有价值的业务知识（新的业务判断、对未来有参考价值的分析、与已有知识的矛盾或补充）。如满足条件，生成简短摘要卡片提议用户确认入库。纯操作指令和无结论的对话不入库。

**联动**：使用 `brand-review-report` 技能生成报告时，在数据提取后自动 Recall 品牌历史，报告完成后自动提议 Ingest 结论。

**详细流程**：参见 `brand-wiki` 技能和 `{WIKI_ROOT}/SCHEMA.md`。
RULES

    echo "  ✓ BrandWiki 规则已写入 AGENTS.md"
fi

# ---- 4. 复制操作手册 ----
echo ""
echo "[4/4] 放置操作手册..."

if [ -f "$SCRIPT_DIR/BrandWiki-操作手册.md" ]; then
    cp "$SCRIPT_DIR/BrandWiki-操作手册.md" "$WIKI_ROOT/BrandWiki-操作手册.md"
    echo "  ✓ 操作手册已放入 $WIKI_ROOT/BrandWiki-操作手册.md"
fi

# ---- 完成 ----
echo ""
echo "=========================================="
echo "  安装完成！"
echo "=========================================="
echo ""
echo "BrandWiki 路径：$WIKI_ROOT"
echo ""
echo "⚠️  还需要手动安装两个技能（参见操作手册第二节）："
echo "  • skills/brand-wiki/       → 拖入 QoderWork 窗口"
echo "  • skills/brand-review-report/ → 拖入 QoderWork 窗口"
echo ""
echo "安装技能后你可以："
echo "  • 在 QoderWork 中将 $WIKI_ROOT 选为工作文件夹（推荐）"
echo "  • 直接在 QoderWork 中说「存入 Wiki」或「查 Wiki」开始使用"
echo "  • 使用 brand-review-report 技能生成报告时，Wiki 会自动联动"
echo "  • 查看操作手册了解更多：$WIKI_ROOT/BrandWiki-操作手册.md"
echo ""
echo "按回车键退出..."
read -r
