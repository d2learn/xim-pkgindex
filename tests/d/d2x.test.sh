# d2x 包测试
if should_run "install"; then assert_install_success "d2x"; fi
if should_run "verify"; then
    assert_command_works "d2x --version 2>&1 | head -1" "d2x --version"
    assert_xvm_registered "d2x"
fi
