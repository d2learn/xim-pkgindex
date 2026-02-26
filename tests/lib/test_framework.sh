#!/bin/bash
# xpkg test framework - 共享测试函数
# 用法: source tests/lib/test_framework.sh

set -euo pipefail

# ─── 颜色 ───
RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; CYAN='\033[36m'; DIM='\033[2m'; RESET='\033[0m'

# ─── 计数器 ───
_PASS=0; _FAIL=0; _SKIP=0; _WARN=0
_CURRENT_PKG=""
_TEST_LEVEL="${TEST_LEVEL:-syntax}"  # syntax | install | verify | isolation | all
_RESULTS_FILE="${RESULTS_FILE:-/tmp/xpkg_test_results.txt}"

# ─── 基础断言 ───

pass() { _PASS=$((_PASS+1)); echo -e "  ${GREEN}✅ PASS${RESET}: $1"; }
fail() { _FAIL=$((_FAIL+1)); echo -e "  ${RED}❌ FAIL${RESET}: $1"; echo "FAIL|${_CURRENT_PKG}|$1" >> "$_RESULTS_FILE"; }
skip() { _SKIP=$((_SKIP+1)); echo -e "  ${DIM}⏩ SKIP${RESET}: $1"; }
warn() { _WARN=$((_WARN+1)); echo -e "  ${YELLOW}⚠️  WARN${RESET}: $1"; echo "WARN|${_CURRENT_PKG}|$1" >> "$_RESULTS_FILE"; }

# ─── 等级检查 ───

should_run() {
    local level="$1"
    case "$_TEST_LEVEL" in
        all) return 0 ;;
        syntax)   [[ "$level" == "syntax" ]] ;;
        install)  [[ "$level" == "syntax" || "$level" == "install" ]] ;;
        verify)   [[ "$level" == "syntax" || "$level" == "install" || "$level" == "verify" ]] ;;
        isolation) [[ "$level" == "syntax" || "$level" == "isolation" ]] ;;
        *) return 1 ;;
    esac
}

# ─── 包定义测试 ───

begin_test() {
    _CURRENT_PKG="$1"
    echo -e "\n${CYAN}━━━ $1 ━━━${RESET}"
}

# 检查 lua 文件是否存在
assert_pkg_file_exists() {
    local pkg_path="$1"
    if [[ -f "$pkg_path" ]]; then
        pass "包文件存在: $pkg_path"
    else
        fail "包文件不存在: $pkg_path"
        return 1
    fi
}

# 检查是否 ref 包
is_ref_package() {
    local pkg_path="$1"
    grep -qP '^\s*package\s*=\s*\{.*\bref\s*=' "$pkg_path" 2>/dev/null
}

# 语法层: xim --add-xpkg 是否通过
assert_xim_add() {
    local pkg_path="$1"
    local output
    output=$(xim --add-xpkg "$pkg_path" 2>&1)
    if echo "$output" | grep -qi "error"; then
        fail "xim --add-xpkg 失败: $(echo "$output" | grep -i error | head -1)"
        return 1
    else
        pass "xim --add-xpkg 注册成功"
    fi
}

# 语法层: 检查必填字段
assert_required_fields() {
    local pkg_path="$1"
    local missing=""
    for field in 'name' 'description' 'type' 'spec'; do
        if ! grep -qP "${field}\s*=" "$pkg_path" 2>/dev/null; then
            missing="$missing $field"
        fi
    done
    if [[ -n "$missing" ]]; then
        fail "缺少必填字段:$missing"
    else
        pass "必填字段完整 (name, description, type, spec)"
    fi
}

# ─── 隔离合规测试 ───

assert_no_exec_xvm() {
    local pkg_path="$1"
    if grep -qP 'os\.exec\(.*xvm\s+add' "$pkg_path" 2>/dev/null; then
        fail "使用 os.exec(\"xvm add ...\") 代替 xvm.add() API"
    else
        pass "未直接 exec 调用 xvm"
    fi
}

assert_no_bashrc_modification() {
    local pkg_path="$1"
    if grep -qP 'append_bashrc|append_to_shell_profile' "$pkg_path" 2>/dev/null; then
        warn "修改了用户 shell 配置 (bashrc/profile)"
    else
        pass "未修改 shell 配置"
    fi
}

assert_no_direct_path_modification() {
    local pkg_path="$1"
    if grep -qP 'os\.addenv\(.*PATH|os\.setenv\(.*PATH' "$pkg_path" 2>/dev/null; then
        warn "直接操作 PATH 环境变量"
    else
        pass "未直接操作 PATH"
    fi
}

assert_no_typo_debain() {
    local pkg_path="$1"
    if grep -qP '\bdebain\b' "$pkg_path" 2>/dev/null; then
        fail "拼写错误: debain (应为 debian)"
    else
        pass "无已知拼写错误"
    fi
}

assert_uses_new_api() {
    local pkg_path="$1"
    if grep -qP 'import\("xim\.base\.runtime"\)' "$pkg_path" 2>/dev/null; then
        warn "使用旧 API: import(\"xim.base.runtime\"), 建议迁移到 xim.libxpkg.*"
    fi
    if grep -qP 'import\("common"\)' "$pkg_path" 2>/dev/null; then
        warn "使用旧 API: import(\"common\")"
    fi
}

# ─── 安装测试 ───

assert_install_success() {
    local pkg_name="$1"
    local output
    output=$(echo y | xlings install "$pkg_name" 2>&1)
    if echo "$output" | grep -qE "installed|already installed"; then
        pass "安装成功: $pkg_name"
    else
        fail "安装失败: $pkg_name"
        return 1
    fi
}

# ─── 验证测试 ───

assert_command_works() {
    local cmd="$1"
    local desc="${2:-$cmd}"
    local output
    output=$(timeout 10 bash -l -c "$cmd" 2>&1)
    local exit_code=$?
    if [[ $exit_code -eq 0 ]] && [[ -n "$output" ]]; then
        pass "$desc → $(echo "$output" | head -1)"
    elif [[ $exit_code -eq 0 ]]; then
        warn "$desc → 命令成功但无输出"
    else
        fail "$desc → exit=$exit_code $(echo "$output" | head -1)"
    fi
}

assert_xvm_registered() {
    local target="$1"
    local info
    info=$(xvm info "$target" 2>&1)
    if echo "$info" | grep -q "Program:"; then
        pass "xvm 已注册: $target"
    else
        fail "xvm 未注册: $target"
    fi
}

assert_platform_has() {
    local pkg_path="$1"
    local platform="$2"
    if grep -qP "^\s*${platform}\s*=" "$pkg_path" 2>/dev/null || \
       grep -qP "^\s*${platform}\s*=\s*\{" "$pkg_path" 2>/dev/null; then
        pass "支持平台: $platform"
    else
        warn "不支持平台: $platform"
    fi
}

# ─── 报告 ───

print_summary() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${GREEN}PASS${RESET}: $_PASS  ${RED}FAIL${RESET}: $_FAIL  ${YELLOW}WARN${RESET}: $_WARN  ${DIM}SKIP${RESET}: $_SKIP"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    if [[ $_FAIL -gt 0 ]]; then
        echo -e "\n${RED}失败项:${RESET}"
        grep "^FAIL|" "$_RESULTS_FILE" 2>/dev/null | while IFS='|' read -r _ pkg msg; do
            echo -e "  ${RED}✗${RESET} $pkg: $msg"
        done
    fi

    if [[ $_WARN -gt 0 ]]; then
        echo -e "\n${YELLOW}警告项:${RESET}"
        grep "^WARN|" "$_RESULTS_FILE" 2>/dev/null | while IFS='|' read -r _ pkg msg; do
            echo -e "  ${YELLOW}!${RESET} $pkg: $msg"
        done
    fi

    [[ $_FAIL -eq 0 ]]
}
