#!/bin/bash
# xpkg 包测试运行器
#
# 用法:
#   ./tests/run_tests.sh                    # 默认: syntax 级别, 测试所有包
#   ./tests/run_tests.sh syntax             # 语法 + 索引注册
#   ./tests/run_tests.sh isolation          # 语法 + subos 隔离合规
#   ./tests/run_tests.sh install            # 语法 + 实际安装
#   ./tests/run_tests.sh verify             # 语法 + 安装 + 运行验证
#   ./tests/run_tests.sh all                # 全部级别
#   ./tests/run_tests.sh syntax nodejs      # 只测指定包
#   ./tests/run_tests.sh verify cmake ninja # 测多个指定包
#
# 测试级别:
#   syntax    - lua 语法、必填字段、xim --add-xpkg 注册
#   isolation - syntax + subos 环境隔离合规检查
#   install   - syntax + 实际安装 (xlings install)
#   verify    - syntax + install + 运行验证 (--version 等)
#   all       - 以上全部

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export TEST_LEVEL="${1:-syntax}"
shift 2>/dev/null || true

export RESULTS_FILE="/tmp/xpkg_test_results_$(date +%s).txt"
> "$RESULTS_FILE"

source "$SCRIPT_DIR/lib/test_framework.sh"

# 确定要测试的包列表
FILTER_PKGS=("$@")

run_test_for_pkg() {
    local pkg_lua="$1"
    local pkg_name
    pkg_name=$(basename "$pkg_lua" .lua)

    # 如果指定了包名过滤
    if [[ ${#FILTER_PKGS[@]} -gt 0 ]]; then
        local found=false
        for fp in "${FILTER_PKGS[@]}"; do
            if [[ "$pkg_name" == "$fp" ]]; then found=true; break; fi
        done
        if ! $found; then return; fi
    fi

    local test_file="$SCRIPT_DIR/${pkg_lua#$ROOT_DIR/pkgs/}"
    test_file="${test_file%.lua}.test.sh"

    begin_test "$pkg_name"

    # ref 包只做最基础检查
    if is_ref_package "$pkg_lua"; then
        pass "ref 包 (别名)"
        return
    fi

    # ── syntax 级别 ──
    if should_run "syntax"; then
        assert_pkg_file_exists "$pkg_lua"
        assert_required_fields "$pkg_lua"
        assert_xim_add "$pkg_lua"
    fi

    # ── isolation 级别 ──
    if should_run "isolation"; then
        assert_no_exec_xvm "$pkg_lua"
        assert_no_bashrc_modification "$pkg_lua"
        assert_no_direct_path_modification "$pkg_lua"
        assert_no_typo_debain "$pkg_lua"
        assert_uses_new_api "$pkg_lua"
    fi

    # ── 自定义测试文件 (install / verify 级别) ──
    if [[ -f "$test_file" ]]; then
        source "$test_file"
    else
        # 没有自定义测试文件时的默认行为
        if should_run "install"; then
            assert_install_success "$pkg_name"
        fi
    fi
}

echo "════════════════════════════════════════════"
echo " xpkg 包测试  级别=$TEST_LEVEL  $(date)"
echo "════════════════════════════════════════════"

for pkg_lua in $(find "$ROOT_DIR/pkgs" -name "*.lua" | sort); do
    run_test_for_pkg "$pkg_lua"
done

print_summary
