# xlings 包测试
if should_run "verify"; then
    assert_command_works "xlings --version 2>&1 | head -1" "xlings --version"
fi
