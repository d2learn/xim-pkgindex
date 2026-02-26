# nodejs 包测试
if should_run "install"; then assert_install_success "nodejs"; fi
if should_run "verify"; then
    assert_command_works "node --version" "node --version"
    assert_command_works "node -e 'console.log(1+1)'" "node 求值"
fi
