# rustup 包测试
if should_run "install"; then assert_install_success "rustup"; fi
if should_run "verify"; then
    assert_command_works "rustup --version 2>&1 | head -1" "rustup --version"
fi
