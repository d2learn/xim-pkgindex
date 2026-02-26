# rust 包测试
if should_run "install"; then assert_install_success "rust"; fi
if should_run "verify"; then
    assert_command_works "rustc --version" "rustc --version"
    assert_command_works "cargo --version" "cargo --version"
fi
