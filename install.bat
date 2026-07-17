@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: BrandWiki 一键安装脚本 (Windows)
:: 双击运行即可完成所有配置
:: ============================================

echo ==========================================
echo   BrandWiki 一键安装
echo ==========================================
echo.

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"

:: ---- 1. 配置路径 ----
echo [1/4] 配置 BrandWiki 路径...

set "CONFIG_FILE=%USERPROFILE%\.qoderworkcn\brand-wiki-path"
set "DEFAULT_PATH=%USERPROFILE%\BrandWiki\"

if exist "%CONFIG_FILE%" (
    set /p EXISTING_PATH=<"%CONFIG_FILE%"
    echo   已有配置：!EXISTING_PATH!
    set /p KEEP="  是否保留现有路径？(y/n，直接回车保留): "
    if /i not "!KEEP!"=="n" (
        set "WIKI_ROOT=!EXISTING_PATH!"
        echo   √ 保留现有路径：!WIKI_ROOT!
    ) else (
        set /p WIKI_ROOT="  请输入 BrandWiki 存放路径（直接回车使用默认 %DEFAULT_PATH%）: "
        if "!WIKI_ROOT!"=="" set "WIKI_ROOT=%DEFAULT_PATH%"
        echo !WIKI_ROOT!>"%CONFIG_FILE%"
        echo   √ 路径已配置：!WIKI_ROOT!
    )
) else (
    if not exist "%USERPROFILE%\.qoderworkcn" mkdir "%USERPROFILE%\.qoderworkcn"
    echo %DEFAULT_PATH%>"%CONFIG_FILE%"
    set "WIKI_ROOT=%DEFAULT_PATH%"
    echo   √ 使用默认路径：!WIKI_ROOT!
)

:: ---- 2. 创建目录结构 ----
echo.
echo [2/4] 创建 BrandWiki 目录结构...

if not exist "!WIKI_ROOT!brands" mkdir "!WIKI_ROOT!brands"
if not exist "!WIKI_ROOT!domain\frameworks" mkdir "!WIKI_ROOT!domain\frameworks"
if not exist "!WIKI_ROOT!domain\patterns" mkdir "!WIKI_ROOT!domain\patterns"
if not exist "!WIKI_ROOT!domain\benchmarks" mkdir "!WIKI_ROOT!domain\benchmarks"
if not exist "!WIKI_ROOT!domain\concepts" mkdir "!WIKI_ROOT!domain\concepts"
if not exist "!WIKI_ROOT!raw\uploads" mkdir "!WIKI_ROOT!raw\uploads"
if not exist "!WIKI_ROOT!raw\reports" mkdir "!WIKI_ROOT!raw\reports"

copy /Y "%SCRIPT_DIR%BrandWiki\SCHEMA.md" "!WIKI_ROOT!SCHEMA.md" >nul

if not exist "!WIKI_ROOT!_log.md" (
    copy /Y "%SCRIPT_DIR%BrandWiki\_log.md" "!WIKI_ROOT!_log.md" >nul
)

if not exist "!WIKI_ROOT!domain\_index.md" (
    copy /Y "%SCRIPT_DIR%BrandWiki\domain\_index.md" "!WIKI_ROOT!domain\_index.md" >nul
)

echo   √ 目录结构已创建

:: ---- 3. 写入 AGENTS.md 规则 ----
echo.
echo [3/4] 写入 AI 行为规则...

set "AGENTS_FILE=%USERPROFILE%\.qoderworkcn\awareness\main\AGENTS.md"
set "AGENTS_DIR=%USERPROFILE%\.qoderworkcn\awareness\main"

if not exist "%AGENTS_DIR%" mkdir "%AGENTS_DIR%"

findstr /C:"BrandWiki 知识库意识规则" "%AGENTS_FILE%" >nul 2>&1
if %errorlevel%==0 (
    echo   √ AGENTS.md 中已存在 BrandWiki 规则，跳过
) else (
    if not exist "%AGENTS_FILE%" (
        echo # AGENTS.md - 工作手册> "%AGENTS_FILE%"
        echo.>> "%AGENTS_FILE%"
    )
    type "%SCRIPT_DIR%agents-rules.txt" >> "%AGENTS_FILE%"
    echo   √ BrandWiki 规则已写入 AGENTS.md
)

:: ---- 4. 复制操作手册 ----
echo.
echo [4/4] 放置操作手册...

if exist "%SCRIPT_DIR%BrandWiki-操作手册.md" (
    copy /Y "%SCRIPT_DIR%BrandWiki-操作手册.md" "!WIKI_ROOT!BrandWiki-操作手册.md" >nul
    echo   √ 操作手册已放入 !WIKI_ROOT!BrandWiki-操作手册.md
)

:: ---- 完成 ----
echo.
echo ==========================================
echo   安装完成！
echo ==========================================
echo.
echo BrandWiki 路径：!WIKI_ROOT!
echo.
echo 还需要手动安装两个技能（参见操作手册第二节）：
echo   * skills\brand-wiki\       - 拖入 QoderWork 窗口
echo   * skills\brand-review-report\ - 拖入 QoderWork 窗口
echo.
echo 安装技能后你可以：
echo   * 在 QoderWork 中将 !WIKI_ROOT! 选为工作文件夹（推荐）
echo   * 直接在 QoderWork 中说「存入 Wiki」或「查 Wiki」开始使用
echo   * 使用 brand-review-report 技能生成报告时，Wiki 会自动联动
echo   * 查看操作手册了解更多：!WIKI_ROOT!BrandWiki-操作手册.md
echo.
pause
