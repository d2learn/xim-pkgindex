# npm 包测试
if should_run "install"; then assert_install_success "npm"; fi
if should_run "verify"; then
    assert_command_works "npm --version" "npm --version"
fi
