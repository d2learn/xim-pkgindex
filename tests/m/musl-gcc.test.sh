# musl-gcc 包测试
if should_run "install"; then assert_install_success "musl-gcc"; fi
if should_run "verify"; then
    assert_command_works "musl-gcc --version 2>&1 | head -1" "musl-gcc --version"
    assert_xvm_registered "musl-gcc"
fi
