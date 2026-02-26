# cmake 包测试
if should_run "install"; then assert_install_success "cmake"; fi
if should_run "verify"; then
    assert_command_works "cmake --version | head -1" "cmake --version"
fi
