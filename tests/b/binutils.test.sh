# binutils 包测试
if should_run "install"; then assert_install_success "binutils"; fi
if should_run "verify"; then
    assert_command_works "ld --version 2>&1 | head -1" "ld --version"
    assert_command_works "as --version 2>&1 | head -1" "as --version"
fi
