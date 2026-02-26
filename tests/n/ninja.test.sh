# ninja 包测试
if should_run "install"; then assert_install_success "ninja"; fi
if should_run "verify"; then
    assert_command_works "ninja --version" "ninja --version"
    assert_xvm_registered "ninja"
fi
