# brew 包测试
if should_run "install"; then assert_install_success "brew"; fi
if should_run "verify"; then
    assert_command_works "brew --version 2>&1 | head -1" "brew --version"
    assert_xvm_registered "brew"
fi
