# VS Code 包测试
if should_run "install"; then assert_install_success "code"; fi
if should_run "verify"; then
    assert_command_works "code --version 2>&1 | head -1" "code --version"
    assert_xvm_registered "code"
    assert_xvm_registered "vscode"
fi
